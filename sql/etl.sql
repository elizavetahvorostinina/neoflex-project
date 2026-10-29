-- etl.sql
-- Зпускается после dwh-schema.sql и dq.sql.
-- Здесь описание процедур, их запуск в run.sql.
-- ПРИМЕЧАНИЕ: исходные таблицы HR/зарплаты должны уже содержать данные.

-- =============================================================
-- Витрина 1: Текучка
-- =============================================================
CREATE OR REPLACE PROCEDURE public.etl_load_turnover()
LANGUAGE plpgsql
AS $$
DECLARE
    v_wm  timestamp;
    v_new timestamp;
BEGIN
    SELECT COALESCE(MAX(last_load_ts), timestamp '1900-01-01')
    INTO v_wm
    FROM public.etl_watermark
    WHERE process_name = 'etl_load_turnover';

    DROP TABLE IF EXISTS pg_temp.tmp_turnover;

    -- Включить ВСЕ измененные назначения (даже те, которые активны в данный момент), чтобы исправленное end_date = NULL удалило бы ранее опубликованное увольнение из базы данных.
    CREATE TEMP TABLE tmp_turnover ON COMMIT DROP AS
    SELECT
        st.assignment_id,
        st.snils,
        st.end_date,
        ri.reason AS reason_for_leaving,
        (st.end_date - st.start_date) AS working_period,
        st.load_date,
        CASE
            WHEN st.end_date IS NULL THEN NULL
            WHEN st.end_date < st.start_date THEN 'CHECK_2'
            WHEN st.reason_id IS NULL OR ri.reason_id IS NULL
              OR cardinality(ri.reason) = 0 THEN 'CHECK_REASON_MISSING'
            ELSE NULL
        END AS reject_code
    FROM public.staffing_table st
    LEFT JOIN public.reason_information ri ON ri.reason_id = st.reason_id
    WHERE st.load_date >= v_wm;

    -- Удаляется старые записи об измененных назначениях
    DELETE FROM public.turnover t
    USING pg_temp.tmp_turnover x
    WHERE t.assignment_id = x.assignment_id;

    DELETE FROM public.turnover_rejected r
    USING pg_temp.tmp_turnover x
    WHERE r.assignment_id = x.assignment_id;

    -- Некорректные завершённые назначения попадают в turnover_rejected, корректные — в turnover.
    INSERT INTO public.turnover_rejected (
        assignment_id, snils, end_date, reason_for_leaving, working_period,
        load_date, rejection_check, rejection_reason
    )
    SELECT
        assignment_id, snils, end_date, reason_for_leaving, working_period,
        load_date, reject_code,
        CASE reject_code
            WHEN 'CHECK_2' THEN 'Дата увольнения раньше даты приёма'
            WHEN 'CHECK_REASON_MISSING' THEN 'Не указана причина увольнения'
        END
    FROM pg_temp.tmp_turnover
    WHERE end_date IS NOT NULL AND reject_code IS NOT NULL;

    -- Предупреждение CHECK_3 не блокирует запись
    INSERT INTO public.turnover (
        assignment_id, snils, end_date, reason_for_leaving, working_period, load_date
    )
    SELECT
        assignment_id, snils, end_date, reason_for_leaving, working_period, load_date
    FROM pg_temp.tmp_turnover
    WHERE end_date IS NOT NULL AND reject_code IS NULL;

    -- Запысывается дата "последнего обновления" 
    SELECT MAX(load_date) INTO v_new FROM pg_temp.tmp_turnover;
    IF v_new IS NOT NULL THEN
        INSERT INTO public.etl_watermark(process_name, last_load_ts)
        VALUES ('etl_load_turnover', v_new)
        ON CONFLICT (process_name) DO UPDATE
        SET last_load_ts = GREATEST(
            etl_watermark.last_load_ts, EXCLUDED.last_load_ts
        );
    END IF;
END;
$$;

-- =============================================================
-- Витрина 2: Изменения ЗП
-- =============================================================
CREATE OR REPLACE PROCEDURE public.etl_load_salary_change()
LANGUAGE plpgsql
AS $$
DECLARE
    v_wm  timestamp;
    v_new timestamp;
BEGIN
    SELECT COALESCE(MAX(last_load_ts), timestamp '1900-01-01')
    INTO v_wm
    FROM public.etl_watermark
    WHERE process_name = 'etl_load_salary_change';

    DROP TABLE IF EXISTS pg_temp.tmp_salary_assignments;
    DROP TABLE IF EXISTS pg_temp.tmp_salary;

    -- Сначала выбираются назначения, по которым изменились данные хотя бы в одном из трёх источников:
    -- employee_salary_history, plan_execution, staffing_table
    CREATE TEMP TABLE tmp_salary_assignments ON COMMIT DROP AS
    SELECT DISTINCT assignment_id
    FROM (
        SELECT assignment_id
        FROM public.employee_salary_history WHERE load_date >= v_wm
        UNION ALL
        SELECT assignment_id
        FROM public.plan_execution WHERE load_date >= v_wm
        UNION ALL
        SELECT assignment_id
        FROM public.staffing_table WHERE load_date >= v_wm
    ) changed;

    -- Восстанавливается история зарплаты   
    CREATE TEMP TABLE tmp_salary ON COMMIT DROP AS
    WITH ordered_salary AS (
        SELECT
            esh.salary_event_id,
            esh.assignment_id,
            esh.salary,
            esh.effective_from,
            esh.load_date,
            esh.reason_id,
            LAG(esh.salary) OVER (
                PARTITION BY esh.assignment_id
                ORDER BY esh.effective_from, esh.salary_event_id
            ) AS previous_salary
        FROM public.employee_salary_history esh
        JOIN pg_temp.tmp_salary_assignments a
          ON a.assignment_id = esh.assignment_id
    )
    SELECT
        os.salary_event_id,
        os.assignment_id,
        st.snils,
        CASE WHEN os.previous_salary <> 0
        -- Расчитывается процент изменения
             THEN ROUND((os.salary - os.previous_salary) * 100.0 / os.previous_salary, 2)  
             ELSE NULL
        END AS salary_change_percent,
        os.previous_salary,
        os.salary AS current_salary,
        pi.post_name,
        public.dq_grade_for_tasks(lp.plan_tasks) AS grade,
        array_to_string(ri.reason, ', ') AS reason_salary_change,
        os.effective_from,
        os.load_date,
        CASE WHEN os.previous_salary = 0
             THEN 'CHECK_SALARY_BASE_ZERO' ELSE NULL
        END AS reject_code
    FROM ordered_salary os
    JOIN public.staffing_table st ON st.assignment_id = os.assignment_id
    JOIN public.post_information pi ON pi.post_id = st.post_id
    LEFT JOIN public.reason_information ri ON ri.reason_id = os.reason_id
    -- находит подходящий план задач на дату изменения зарплаты +
    LEFT JOIN LATERAL (
        SELECT pe.plan_tasks, pe.fact_tasks
        FROM public.plan_execution pe
        WHERE pe.assignment_id = os.assignment_id
          AND pe.start_date <= os.effective_from
          AND (pe.end_date IS NULL OR pe.end_date >= os.effective_from)
        ORDER BY pe.start_date DESC, pe.load_date DESC, pe.plan_id DESC
        LIMIT 1
    ) lp ON TRUE
    WHERE os.previous_salary IS NOT NULL
      AND os.salary IS DISTINCT FROM os.previous_salary;

    -- По всем затронутым назначениям удаляются старые строки
    DELETE FROM public.salary_change sc
    USING pg_temp.tmp_salary_assignments a
    WHERE sc.assignment_id = a.assignment_id;

    DELETE FROM public.salary_change_rejected r
    USING pg_temp.tmp_salary_assignments a
    WHERE r.assignment_id = a.assignment_id;

    -- Если предыдущая зарплата равна нулю, запись поступает в карантин. Остальные рассчитанные изменения — в витрину
    INSERT INTO public.salary_change_rejected (
        salary_event_id, assignment_id, snils, salary_change_percent,
        previous_salary, current_salary, post_name, grade,
        reason_salary_change, effective_from, load_date,
        rejection_check, rejection_reason
    )
    SELECT
        salary_event_id, assignment_id, snils, salary_change_percent,
        previous_salary, current_salary, post_name, grade,
        reason_salary_change, effective_from, load_date,
        reject_code, 'Нельзя вычислить процент: предыдущая зарплата равна 0'
    FROM pg_temp.tmp_salary
    WHERE reject_code IS NOT NULL;

    INSERT INTO public.salary_change (
        salary_event_id, assignment_id, snils, salary_change_percent,
        previous_salary, current_salary, post_name, grade,
        reason_salary_change, effective_from, load_date
    )
    SELECT
        salary_event_id, assignment_id, snils, salary_change_percent,
        previous_salary, current_salary, post_name, grade,
        reason_salary_change, effective_from, load_date
    FROM pg_temp.tmp_salary
    WHERE reject_code IS NULL;

    -- Обновляются контрольные точки
    SELECT MAX(load_date)
    INTO v_new
    FROM (
        SELECT load_date FROM public.employee_salary_history WHERE load_date >= v_wm
        UNION ALL
        SELECT load_date FROM public.plan_execution WHERE load_date >= v_wm
        UNION ALL
        SELECT load_date FROM public.staffing_table WHERE load_date >= v_wm
    ) changed;

    IF v_new IS NOT NULL THEN
        INSERT INTO public.etl_watermark(process_name, last_load_ts)
        VALUES ('etl_load_salary_change', v_new)
        ON CONFLICT (process_name) DO UPDATE
        SET last_load_ts = GREATEST(
            etl_watermark.last_load_ts, EXCLUDED.last_load_ts
        );
    END IF;
END;
$$;

-- =============================================================
-- Оркестратор
-- =============================================================
CREATE OR REPLACE PROCEDURE public.etl_run_all()
LANGUAGE plpgsql
AS $$
DECLARE
    v_run_id bigint;
    v_error text;
BEGIN
    -- Блокирует параллельные запуски, чтобы два экземпляра оркестратора не работали одновременно.
    PERFORM pg_advisory_xact_lock(58214027::bigint);

    INSERT INTO public.etl_run(status)
    VALUES ('RUNNING')
    RETURNING run_id INTO v_run_id;

    -- Обновляем витрины, проводим проверки качества, фиксируем результат и время завершения
    BEGIN
        CALL public.etl_load_turnover();
        CALL public.etl_load_salary_change();
        CALL public.dq_run_checks(v_run_id);

        UPDATE public.etl_run
        SET status = 'SUCCESS', finished_at = clock_timestamp()
        WHERE run_id = v_run_id;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
        UPDATE public.etl_run
        SET status = 'FAILED', finished_at = clock_timestamp()
        WHERE run_id = v_run_id;
        RAISE WARNING 'ETL run_id=% FAILED: %. See etl_run.', v_run_id, v_error;
    END;
END;
$$;