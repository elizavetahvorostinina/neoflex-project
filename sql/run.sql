-- run.sql
-- Выполнить после запуска, в порядке очереди:
--   dwh-schema.sql
--   dq.sql
--   etl.sql
--   demo_data.sql


CALL public.etl_run_all();

-- Определяет последний запуск и его результат
SELECT run_id, started_at, finished_at, status
FROM public.etl_run
ORDER BY run_id DESC
LIMIT 1;

-- Результаты DQ по последнему запуску (история предыдущих запусков сохранена).
SELECT issue_id, run_id, check_code, severity, entity,
       row_key, message_txt, detected_at
FROM public.dq_issue
WHERE run_id = (SELECT MAX(run_id) FROM public.etl_run)
ORDER BY check_code, severity, entity, row_key;

-- Результаты обеих витрин и карантина
SELECT 'turnover' AS dataset, COUNT(*) AS row_count FROM public.turnover
UNION ALL
SELECT 'salary_change', COUNT(*) FROM public.salary_change
UNION ALL
SELECT 'turnover_rejected', COUNT(*) FROM public.turnover_rejected
UNION ALL
SELECT 'salary_change_rejected', COUNT(*) FROM public.salary_change_rejected;

-- Записи о карантине
SELECT * FROM public.turnover_rejected ORDER BY rejected_at DESC LIMIT 100;
SELECT * FROM public.salary_change_rejected ORDER BY rejected_at DESC LIMIT 100;

-- Контрольные точки ETL
SELECT process_name, last_load_ts
FROM public.etl_watermark
ORDER BY process_name;

-- Пример аналитических данных: увольнения и изменения зарплат сотрудников по месяцам.
SELECT date_trunc('month', end_date)::date AS month,
       COUNT(*) AS dismissal_count,
       ROUND(AVG(working_period), 2) AS avg_working_days
FROM public.turnover
GROUP BY 1 ORDER BY 1;

SELECT date_trunc('month', effective_from)::date AS month,
       COUNT(*) AS salary_changes,
       COUNT(*) FILTER (WHERE salary_change_percent > 0) AS increases,
       COUNT(*) FILTER (WHERE salary_change_percent < 0) AS decreases,
       ROUND(AVG(salary_change_percent), 2) AS avg_change_percent
FROM public.salary_change
GROUP BY 1 ORDER BY 1;