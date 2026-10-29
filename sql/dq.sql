-- dq.sql
-- Запуск после dwh-schema.sql и перед etl.sql.
-- Критические строки помещаются в карантин ETL, если это правило является условием отклонения.
CREATE OR REPLACE FUNCTION public.dq_grade_for_tasks(p_tasks integer)
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN p_tasks BETWEEN 0 AND 50 THEN 'джун'
        WHEN p_tasks BETWEEN 51 AND 100 THEN 'мидл'
        WHEN p_tasks BETWEEN 101 AND 150 THEN 'сеньор'
        ELSE 'Не определён'
    END;
$$;

CREATE OR REPLACE PROCEDURE public.dq_run_checks(IN p_run_id bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.etl_run WHERE run_id = p_run_id) THEN
        RAISE EXCEPTION 'Unknown etl_run.run_id: %', p_run_id;
    END IF;

    -- Повторный запуск DQ для существующего прогона является идемпотентным и не приводит к удалению истории
    DELETE FROM public.dq_issue WHERE run_id = p_run_id;

    -- CHECK_1: >30% NULL в reason
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    WITH batch_quality AS (
        SELECT
            s.batch_id,
            COUNT(*) AS total_cnt,
            COUNT(*) FILTER (
                WHERE s.reason IS NULL
                   OR cardinality(s.reason) = 0
                   OR EXISTS (
                       SELECT 1
                       FROM unnest(s.reason) AS r(reason_item)
                       WHERE NULLIF(btrim(r.reason_item), '') IS NULL
                   )
            ) AS missing_cnt
        FROM public.stg_reason_information s
        GROUP BY s.batch_id
    )
    SELECT
        p_run_id, 'CHECK_1', 'CRITICAL', 'stg_reason_information', batch_id,
        format('Причина не заполнена: %s%% (%s из %s)',
               round(missing_cnt * 100.0 / total_cnt, 2), missing_cnt, total_cnt)
    FROM batch_quality
    WHERE total_cnt > 0 AND missing_cnt * 100.0 / total_cnt > 30;


    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    WITH dismissal_quality AS (
        SELECT
            COUNT(*) AS total_cnt,
            COUNT(*) FILTER (
                WHERE st.reason_id IS NULL OR ri.reason_id IS NULL
                   OR cardinality(ri.reason) = 0
            ) AS missing_cnt
        FROM public.staffing_table st
        LEFT JOIN public.reason_information ri ON ri.reason_id = st.reason_id
        WHERE st.end_date IS NOT NULL
    )
    SELECT
        p_run_id, 'CHECK_1', 'CRITICAL', 'staffing_table', 'all_dismissals',
        format('Неизвестная причина увольнения: %s%% (%s из %s)',
               round(missing_cnt * 100.0 / total_cnt, 2), missing_cnt, total_cnt)
    FROM dismissal_quality
    WHERE total_cnt > 0 AND missing_cnt * 100.0 / total_cnt > 30;

    -- CHECK_2: Консистентность дат: увольнение раньше приёма
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_2', 'CRITICAL', 'staffing_table', st.assignment_id::text,
        format('Увольнение %s раньше приёма %s', st.end_date, st.start_date)
    FROM public.staffing_table st
    WHERE st.end_date IS NOT NULL AND st.end_date < st.start_date;

    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_2', 'CRITICAL', 'stg_staffing_table', s.source_row_id::text,
        format('Увольнение %s раньше приёма %s', s.end_date, s.start_date)
    FROM public.stg_staffing_table s
    WHERE s.end_date IS NOT NULL AND s.start_date IS NOT NULL
      AND s.end_date < s.start_date;

    -- CHECK_3: Соответствие причины периоду работы
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_3', 'WARNING', 'staffing_table', st.assignment_id::text,
        'Причина увольнения нетипична для периода работы; правило учебное'
    FROM public.staffing_table st
    JOIN public.reason_information ri ON ri.reason_id = st.reason_id
    WHERE st.end_date IS NOT NULL
      AND st.end_date >= st.start_date
      AND (
          (st.end_date - st.start_date <= 60
            AND NOT COALESCE('Несоответствие ожиданий' = ANY(ri.reason), false))
          OR
          (st.end_date - st.start_date BETWEEN 730 AND 1095
            AND NOT (
                COALESCE('Выгорание' = ANY(ri.reason), false)
                OR COALESCE('Поиск карьерного роста' = ANY(ri.reason), false)
            ))
      );

    -- CHECK_4: Согласованность: висячие объекты
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_4', 'CRITICAL', 'stg_staffing_table', s.source_row_id::text,
        'Нет сотрудника / должности / указанной причины в справочниках'
    FROM public.stg_staffing_table s
    LEFT JOIN public.people p ON p.snils = s.snils
    LEFT JOIN public.post_information pi ON pi.post_id = s.post_id
    LEFT JOIN public.reason_information ri ON ri.reason_id = s.reason_id
    WHERE (
        s.snils IS NULL OR (
            p.snils IS NULL AND NOT EXISTS (
                SELECT 1 FROM public.stg_people sp
                WHERE sp.batch_id = s.batch_id AND sp.snils = s.snils
            )
        )
    )
       OR pi.post_id IS NULL
       OR (
           s.reason_id IS NOT NULL AND ri.reason_id IS NULL
           AND NOT EXISTS (
               SELECT 1 FROM public.stg_reason_information sr
               WHERE sr.batch_id = s.batch_id AND sr.reason_id = s.reason_id
                 AND sr.reason IS NOT NULL AND cardinality(sr.reason) > 0
           )
       );

    -- CHECK_5: Дублирование: Уникальность СНИЛСа
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_5', 'CRITICAL', 'stg_people',
        batch_id || '|' || normalized_snils,
        format('Повторяется СНИЛС: %s записей в партии %s', COUNT(*), batch_id)
    FROM (
        SELECT batch_id, btrim(snils) AS normalized_snils
        FROM public.stg_people
        WHERE snils IS NOT NULL AND btrim(snils) <> ''
    ) src
    GROUP BY batch_id, normalized_snils
    HAVING COUNT(*) > 1;

    -- CHECK_6: Несоответсвие уровня ЗП занимаемой должности
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    WITH salary_and_grade AS (
        SELECT
            esh.salary_event_id, esh.salary,
            public.dq_grade_for_tasks(lp.plan_tasks) AS grade
        FROM public.employee_salary_history esh
        LEFT JOIN LATERAL (
            SELECT pe.plan_tasks
            FROM public.plan_execution pe
            WHERE pe.assignment_id = esh.assignment_id
              AND pe.start_date <= esh.effective_from
              AND (pe.end_date IS NULL OR pe.end_date >= esh.effective_from)
            ORDER BY pe.start_date DESC, pe.load_date DESC, pe.plan_id DESC
            LIMIT 1
        ) lp ON TRUE
    )
    SELECT
        p_run_id, 'CHECK_6', 'WARNING', 'employee_salary_history',
        salary_event_id::text,
        format('Зарплата %s не соответствует условному грейду %s', salary, grade)
    FROM salary_and_grade
    WHERE (grade = 'джун' AND salary > 50000)
       OR (grade = 'мидл' AND (salary < 50000 OR salary > 100000))
       OR (grade = 'сеньор' AND salary < 100000);

    -- CHECK_7: Правильность грейда по плану/факту. Предупреждение о категориях загруженности задачами, 
    INSERT INTO public.dq_issue
        (run_id, check_code, severity, entity, row_key, message_txt)
    SELECT
        p_run_id, 'CHECK_7', 'WARNING', 'plan_execution', pe.plan_id::text,
        format('План %s (%s), факт %s (%s): разные диапазоны нагрузки',
               pe.plan_tasks, public.dq_grade_for_tasks(pe.plan_tasks),
               pe.fact_tasks, public.dq_grade_for_tasks(pe.fact_tasks))
    FROM public.plan_execution pe
    WHERE pe.fact_tasks > pe.plan_tasks
      AND public.dq_grade_for_tasks(pe.plan_tasks) <> 'Не определён'
      AND public.dq_grade_for_tasks(pe.fact_tasks) <> 'Не определён'
      AND public.dq_grade_for_tasks(pe.plan_tasks)
          <> public.dq_grade_for_tasks(pe.fact_tasks);
END;
$$;
