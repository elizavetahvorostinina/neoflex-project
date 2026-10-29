-- demo_data.sql
-- Псоле выполните run.sql, который вызывает etl_run_all().

BEGIN;

-- 1. Справочник сотрудников 
INSERT INTO public.people (snils, surname, name, middle_name, birth_date, gender, education_level, city, start_date, end_date, status)
VALUES
    ('TEST-000000001', 'Иванов', 'Артём', 'Сергеевич', DATE '1993-04-06', 'М', 'Высшее', 'Санкт-Петербург', DATE '2024-02-01', DATE '2026-02-15', 'inactive'),
    ('TEST-000000002', 'Петрова', 'Мария', 'Андреевна', DATE '2000-07-11', 'Ж', 'Высшее', 'Казань', DATE '2025-04-01', DATE '2026-01-12', 'inactive'),
    ('TEST-000000003', 'Смирнов', 'Денис', 'Олегович', DATE '1992-10-16', 'М', 'Высшее', 'Новосибирск', DATE '2024-02-01', NULL, 'active'),
    ('TEST-000000004', 'Кузнецова', 'Анна', 'Игоревна', DATE '1999-01-21', 'Ж', 'Высшее', 'Екатеринбург', DATE '2025-06-01', DATE '2025-07-05', 'inactive'),
    ('TEST-000000005', 'Попов', 'Максим', 'Дмитриевич', DATE '1991-04-26', 'М', 'Среднее специальное', 'Нижний Новгород', DATE '2024-08-01', NULL, 'active'),
    ('TEST-000000006', 'Васильева', 'Елена', 'Павловна', DATE '1998-07-04', 'Ж', 'Высшее', 'Самара', DATE '2025-01-20', DATE '2026-07-22', 'inactive'),
    ('TEST-000000007', 'Соколов', 'Никита', 'Алексеевич', DATE '1990-10-09', 'М', 'Высшее', 'Москва', DATE '2024-02-01', DATE '2026-06-01', 'inactive'),
    ('TEST-000000008', 'Михайлова', 'Ольга', 'Викторовна', DATE '1997-01-14', 'Ж', 'Высшее', 'Санкт-Петербург', DATE '2024-02-01', NULL, 'active'),
    ('TEST-000000009', 'Новиков', 'Роман', 'Ильич', DATE '1989-04-19', 'М', 'Высшее', 'Казань', DATE '2023-09-01', DATE '2026-03-01', 'inactive'),
    ('TEST-000000010', 'Фёдорова', 'Дарья', 'Романовна', DATE '1996-07-24', 'Ж', 'Среднее специальное', 'Новосибирск', DATE '2024-11-01', NULL, 'active'),
    ('TEST-000000011', 'Морозов', 'Кирилл', 'Сергеевич', DATE '1988-10-02', 'М', 'Высшее', 'Екатеринбург', DATE '2025-09-01', DATE '2026-01-15', 'inactive'),
    ('TEST-000000012', 'Волкова', 'Софья', 'Ивановна', DATE '1995-01-07', 'Ж', 'Высшее', 'Нижний Новгород', DATE '2024-07-01', NULL, 'active'),
    ('TEST-000000013', 'Алексеев', 'Павел', 'Николаевич', DATE '1987-04-12', 'М', 'Высшее', 'Самара', DATE '2024-07-01', DATE '2026-08-10', 'inactive'),
    ('TEST-000000014', 'Лебедева', 'Алина', 'Олеговна', DATE '1994-07-17', 'Ж', 'Высшее', 'Москва', DATE '2025-01-01', DATE '2025-02-10', 'inactive'),
    ('TEST-000000015', 'Семёнов', 'Даниил', 'Егорович', DATE '1986-10-22', 'М', 'Среднее специальное', 'Санкт-Петербург', DATE '2024-04-01', NULL, 'active'),
    ('TEST-000000016', 'Егорова', 'Екатерина', 'Ильинична', DATE '1993-01-27', 'Ж', 'Высшее', 'Казань', DATE '2025-12-01', DATE '2026-07-01', 'inactive'),
    ('TEST-000000017', 'Павлов', 'Михаил', 'Петрович', DATE '2000-04-05', 'М', 'Высшее', 'Новосибирск', DATE '2024-01-01', NULL, 'active'),
    ('TEST-000000018', 'Козлова', 'Полина', 'Денисовна', DATE '1992-07-10', 'Ж', 'Высшее', 'Екатеринбург', DATE '2024-10-01', DATE '2026-06-15', 'inactive'),
    ('TEST-000000019', 'Степанов', 'Андрей', 'Владимирович', DATE '1999-10-15', 'М', 'Высшее', 'Нижний Новгород', DATE '2024-03-01', NULL, 'active'),
    ('TEST-000000020', 'Николаева', 'Татьяна', 'Сергеевна', DATE '1991-01-20', 'Ж', 'Среднее специальное', 'Самара', DATE '2025-01-01', DATE '2026-01-31', 'inactive'),
    ('TEST-000000021', 'Орлов', 'Илья', 'Алексеевич', DATE '1998-04-25', 'М', 'Высшее', 'Москва', DATE '2025-03-20', NULL, 'active'),
    ('TEST-000000022', 'Андреева', 'Юлия', 'Максимовна', DATE '1990-07-03', 'Ж', 'Высшее', 'Санкт-Петербург', DATE '2024-05-01', DATE '2026-09-15', 'inactive'),
    ('TEST-000000023', 'Макаров', 'Александр', 'Павлович', DATE '1997-10-08', 'М', 'Высшее', 'Казань', DATE '2025-03-01', NULL, 'active'),
    ('TEST-000000024', 'Захарова', 'Виктория', 'Денисовна', DATE '1989-01-13', 'Ж', 'Высшее', 'Новосибирск', DATE '2025-01-10', DATE '2026-05-25', 'inactive'),
    ('TEST-000000025', 'Беляев', 'Тимофей', 'Андреевич', DATE '1996-04-18', 'М', 'Среднее специальное', 'Екатеринбург', DATE '2025-10-01', NULL, 'active'),
    ('TEST-000000026', 'Тарасова', 'Наталья', 'Романовна', DATE '1988-07-23', 'Ж', 'Высшее', 'Нижний Новгород', DATE '2025-06-01', DATE '2026-09-01', 'inactive'),
    ('TEST-000000027', 'Борисов', 'Глеб', 'Михайлович', DATE '1995-10-01', 'М', 'Высшее', 'Самара', DATE '2026-01-01', NULL, 'active'),
    ('TEST-000000028', 'Комарова', 'Анастасия', 'Петровна', DATE '1987-01-06', 'Ж', 'Высшее', 'Москва', DATE '2024-12-01', DATE '2026-04-10', 'inactive'),
    ('TEST-000000029', 'Сидоров', 'Егор', 'Николаевич', DATE '1994-04-11', 'М', 'Высшее', 'Санкт-Петербург', DATE '2026-06-15', NULL, 'inactive'),
    ('TEST-000000030', 'Григорьева', 'Ксения', 'Сергеевна', DATE '1986-07-16', 'Ж', 'Среднее специальное', 'Казань', DATE '2025-10-01', DATE '2026-02-28', 'inactive')
ON CONFLICT (snils) DO UPDATE SET surname=EXCLUDED.surname, name=EXCLUDED.name, middle_name=EXCLUDED.middle_name, birth_date=EXCLUDED.birth_date, gender=EXCLUDED.gender, education_level=EXCLUDED.education_level, city=EXCLUDED.city, start_date=EXCLUDED.start_date, end_date=EXCLUDED.end_date, status=EXCLUDED.status;

-- 2. Справочник постов
INSERT INTO public.post_information (post_id, structural_division, post_name, position_count, skills, start_date, end_date, status)
VALUES
    (101, 'Аналитика', 'Аналитик данных', 4, 'SQL, Excel, BI', DATE '2023-01-01', NULL, 'active'),
    (102, 'Аналитика', 'Ведущий аналитик', 3, 'SQL, Python, BI', DATE '2023-01-01', NULL, 'active'),
    (103, 'Инженерия', 'Инженер данных', 5, 'SQL, Python, ETL', DATE '2023-01-01', NULL, 'active'),
    (104, 'HR', 'HR-специалист', 3, 'КДП, аналитика', DATE '2023-01-01', NULL, 'active'),
    (105, 'HR', 'Рекрутер', 4, 'Подбор, интервью', DATE '2023-01-01', NULL, 'active'),
    (106, 'Поддержка', 'Специалист поддержки', 8, 'CRM, коммуникации', DATE '2023-01-01', NULL, 'active'),
    (107, 'Управление', 'Руководитель группы', 3, 'Лидерство, планирование', DATE '2023-01-01', NULL, 'active'),
    (108, 'Дизайн', 'UX/UI дизайнер', 4, 'Figma, UX', DATE '2023-01-01', NULL, 'active'),
    (109, 'Продукт', 'Продакт-менеджер', 3, 'Roadmap, аналитика', DATE '2023-01-01', NULL, 'active'),
    (110, 'Качество', 'Тестировщик', 5, 'Тест-кейсы, QA', DATE '2023-01-01', NULL, 'active'),
    (111, 'Финансы', 'Финансовый аналитик', 4, 'Excel, финансовые модели', DATE '2023-01-01', NULL, 'active'),
    (112, 'Аналитика', 'BI-аналитик', 4, 'SQL, Power BI', DATE '2023-01-01', NULL, 'active')
ON CONFLICT (post_id) DO UPDATE SET structural_division=EXCLUDED.structural_division, post_name=EXCLUDED.post_name, position_count=EXCLUDED.position_count, skills=EXCLUDED.skills, start_date=EXCLUDED.start_date, end_date=EXCLUDED.end_date, status=EXCLUDED.status;

-- 3. Справочник причин (увольнение, зп, перевод)
INSERT INTO public.reason_information (reason_id, reason_type, reason)
VALUES
    (1, 'dismissal', ARRAY['По собственному желанию']::text[]),
    (2, 'dismissal', ARRAY['Переезд']::text[]),
    (3, 'dismissal', ARRAY['Несоответствие ожиданий']::text[]),
    (4, 'dismissal', ARRAY['Выгорание']::text[]),
    (5, 'dismissal', ARRAY['Поиск карьерного роста']::text[]),
    (6, 'dismissal', ARRAY['Семейные обстоятельства']::text[]),
    (7, 'salary', ARRAY['Ежегодная индексация']::text[]),
    (8, 'salary', ARRAY['Повышение квалификации']::text[]),
    (9, 'salary', ARRAY['Пересмотр оклада']::text[]),
    (10, 'salary', ARRAY['Изменение обязанностей']::text[]),
    (11, 'transfer', ARRAY['Внутренний перевод']::text[]),
    (12, 'salary', ARRAY['Корректировка оклада']::text[])
ON CONFLICT (reason_id) DO UPDATE SET reason_type=EXCLUDED.reason_type, reason=EXCLUDED.reason;

-- 4. ЗП по должностям
INSERT INTO public.post_salary (post_id, salary, start_date, end_date, load_date)
VALUES
    (101, 65000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (102, 130000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (103, 140000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (104, 70000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (105, 60000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (106, 46000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (107, 160000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (108, 110000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (109, 155000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (110, 65000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (111, 97000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp),
    (112, 88000, DATE '2026-01-01', NULL, '2026-01-01 09:00:00'::timestamp)
ON CONFLICT (post_id, load_date) DO UPDATE SET salary=EXCLUDED.salary, start_date=EXCLUDED.start_date, end_date=EXCLUDED.end_date;

-- 5. Штатное расписание
WITH src (snils,post_id,reason_id,start_date,end_date) AS (
    VALUES
        ('TEST-000000001', 101, 4, DATE '2024-02-01', DATE '2026-02-15'),
        ('TEST-000000002', 106, 2, DATE '2025-04-01', DATE '2026-01-12'),
        ('TEST-000000003', 101, 11, DATE '2024-02-01', DATE '2025-02-14'),
        ('TEST-000000003', 103, NULL, DATE '2025-02-15', NULL),
        ('TEST-000000004', 105, 3, DATE '2025-06-01', DATE '2025-07-05'),
        ('TEST-000000005', 104, NULL, DATE '2024-08-01', NULL),
        ('TEST-000000006', 108, 1, DATE '2025-01-20', DATE '2026-07-22'),
        ('TEST-000000007', 109, 5, DATE '2024-02-01', DATE '2026-06-01'),
        ('TEST-000000008', 106, 11, DATE '2024-02-01', DATE '2025-05-31'),
        ('TEST-000000008', 110, NULL, DATE '2025-06-01', NULL),
        ('TEST-000000009', 102, 4, DATE '2023-09-01', DATE '2026-03-01'),
        ('TEST-000000010', 111, NULL, DATE '2024-11-01', NULL),
        ('TEST-000000011', 101, 2, DATE '2025-09-01', DATE '2026-01-15'),
        ('TEST-000000012', 101, 11, DATE '2024-07-01', DATE '2025-02-28'),
        ('TEST-000000012', 112, NULL, DATE '2025-03-01', NULL),
        ('TEST-000000013', 107, 6, DATE '2024-07-01', DATE '2026-08-10'),
        ('TEST-000000014', 106, 1, DATE '2025-01-01', DATE '2025-02-10'),
        ('TEST-000000015', 103, NULL, DATE '2024-04-01', NULL),
        ('TEST-000000016', 105, 1, DATE '2025-12-01', DATE '2026-07-01'),
        ('TEST-000000017', 105, 11, DATE '2024-01-01', DATE '2025-04-14'),
        ('TEST-000000017', 104, NULL, DATE '2025-04-15', NULL),
        ('TEST-000000018', 108, 2, DATE '2024-10-01', DATE '2026-06-15'),
        ('TEST-000000019', 109, NULL, DATE '2024-03-01', NULL),
        ('TEST-000000020', 110, 3, DATE '2025-01-01', DATE '2026-01-31'),
        ('TEST-000000021', 111, NULL, DATE '2025-03-20', NULL),
        ('TEST-000000022', 112, 4, DATE '2024-05-01', DATE '2026-09-15'),
        ('TEST-000000023', 102, NULL, DATE '2025-03-01', NULL),
        ('TEST-000000024', 101, 6, DATE '2025-01-10', DATE '2026-05-25'),
        ('TEST-000000025', 106, NULL, DATE '2025-10-01', NULL),
        ('TEST-000000026', 103, 1, DATE '2025-06-01', DATE '2026-09-01'),
        ('TEST-000000027', 105, NULL, DATE '2026-01-01', NULL),
        ('TEST-000000028', 107, 2, DATE '2024-12-01', DATE '2026-04-10'),
        ('TEST-000000029', 108, 2, DATE '2026-06-15', DATE '2026-05-20'),
        ('TEST-000000030', 110, NULL, DATE '2025-10-01', DATE '2026-02-28')
)
INSERT INTO public.staffing_table (snils, post_id, reason_id, start_date, end_date, load_date)
SELECT snils, post_id, reason_id, start_date, end_date, clock_timestamp() FROM src
WHERE true
ON CONFLICT (snils,post_id,start_date) DO UPDATE
SET reason_id=EXCLUDED.reason_id, end_date=EXCLUDED.end_date, load_date=clock_timestamp();

-- 6. План/факт по назначению
WITH src (plan_id,snils,post_id,assignment_start,plan_tasks,fact_tasks,plan_start,plan_end) AS (
    VALUES
        (5001, 'TEST-000000001', 101, DATE '2024-02-01', 90, 83, DATE '2024-02-01', DATE '2025-08-31'),
        (5002, 'TEST-000000001', 101, DATE '2024-02-01', 120, 128, DATE '2025-09-01', DATE '2026-02-15'),
        (5003, 'TEST-000000002', 106, DATE '2025-04-01', 45, 45, DATE '2025-04-01', DATE '2026-01-12'),
        (5004, 'TEST-000000003', 101, DATE '2024-02-01', 40, 47, DATE '2024-02-01', DATE '2025-02-14'),
        (5005, 'TEST-000000003', 103, DATE '2025-02-15', 55, 62, DATE '2025-02-15', DATE '2025-12-31'),
        (5006, 'TEST-000000003', 103, DATE '2025-02-15', 115, 123, DATE '2026-01-01', NULL),
        (5007, 'TEST-000000004', 105, DATE '2025-06-01', 45, 75, DATE '2025-06-01', DATE '2025-07-05'),
        (5008, 'TEST-000000005', 104, DATE '2024-08-01', 70, 56, DATE '2024-08-01', NULL),
        (5009, 'TEST-000000006', 108, DATE '2025-01-20', 105, 98, DATE '2025-01-20', DATE '2026-07-22'),
        (5010, 'TEST-000000007', 109, DATE '2024-02-01', 75, 75, DATE '2024-02-01', DATE '2026-06-01'),
        (5011, 'TEST-000000008', 106, DATE '2024-02-01', 35, 42, DATE '2024-02-01', DATE '2025-05-31'),
        (5012, 'TEST-000000008', 110, DATE '2025-06-01', 70, 77, DATE '2025-06-01', NULL),
        (5013, 'TEST-000000009', 102, DATE '2023-09-01', 125, 139, DATE '2023-09-01', DATE '2026-03-01'),
        (5014, 'TEST-000000010', 111, DATE '2024-11-01', 95, 81, DATE '2024-11-01', NULL),
        (5015, 'TEST-000000011', 101, DATE '2025-09-01', 40, 72, DATE '2025-09-01', DATE '2026-01-15'),
        (5016, 'TEST-000000012', 101, DATE '2024-07-01', 40, 40, DATE '2024-07-01', DATE '2025-02-28'),
        (5017, 'TEST-000000012', 112, DATE '2025-03-01', 48, 70, DATE '2025-03-01', DATE '2025-12-31'),
        (5018, 'TEST-000000012', 112, DATE '2025-03-01', 85, 93, DATE '2026-01-01', NULL),
        (5019, 'TEST-000000013', 107, DATE '2024-07-01', 145, 152, DATE '2024-07-01', DATE '2026-08-10'),
        (5020, 'TEST-000000014', 106, DATE '2025-01-01', 25, 39, DATE '2025-01-01', DATE '2025-02-10'),
        (5021, 'TEST-000000015', 103, DATE '2024-04-01', 48, 34, DATE '2024-04-01', NULL),
        (5022, 'TEST-000000016', 105, DATE '2025-12-01', 135, 128, DATE '2025-12-01', DATE '2026-07-01'),
        (5023, 'TEST-000000017', 105, DATE '2024-01-01', 45, 45, DATE '2024-01-01', DATE '2025-04-14'),
        (5024, 'TEST-000000017', 104, DATE '2025-04-15', 75, 75, DATE '2025-04-15', NULL),
        (5025, 'TEST-000000018', 108, DATE '2024-10-01', 110, 117, DATE '2024-10-01', DATE '2026-06-15'),
        (5026, 'TEST-000000019', 109, DATE '2024-03-01', 70, 84, DATE '2024-03-01', NULL),
        (5027, 'TEST-000000020', 110, DATE '2025-01-01', 40, 26, DATE '2025-01-01', DATE '2026-01-31'),
        (5028, 'TEST-000000021', 111, DATE '2025-03-20', 65, 58, DATE '2025-03-20', NULL),
        (5029, 'TEST-000000022', 112, DATE '2024-05-01', 125, 125, DATE '2024-05-01', DATE '2026-09-15'),
        (5030, 'TEST-000000023', 102, DATE '2025-03-01', 105, 112, DATE '2025-03-01', NULL),
        (5031, 'TEST-000000024', 101, DATE '2025-01-10', 45, 59, DATE '2025-01-10', DATE '2026-05-25'),
        (5032, 'TEST-000000025', 106, DATE '2025-10-01', 20, 6, DATE '2025-10-01', NULL),
        (5033, 'TEST-000000026', 103, DATE '2025-06-01', 110, 103, DATE '2025-06-01', DATE '2026-09-01'),
        (5034, 'TEST-000000027', 105, DATE '2026-01-01', 40, 40, DATE '2026-01-01', NULL),
        (5035, 'TEST-000000028', 107, DATE '2024-12-01', 140, 147, DATE '2024-12-01', DATE '2026-04-10'),
        (5036, 'TEST-000000029', 108, DATE '2026-06-15', 75, 89, DATE '2026-06-15', NULL),
        (5037, 'TEST-000000030', 110, DATE '2025-10-01', 45, 31, DATE '2025-10-01', DATE '2026-02-28')
)
INSERT INTO public.plan_execution (plan_id, assignment_id, plan_tasks, fact_tasks, start_date, end_date, load_date, record_source)
SELECT v.plan_id, s.assignment_id, v.plan_tasks, v.fact_tasks, v.plan_start, v.plan_end, clock_timestamp(), 'demo_seed'
FROM src v JOIN public.staffing_table s
 ON s.snils=v.snils AND s.post_id=v.post_id AND s.start_date=v.assignment_start
WHERE true
ON CONFLICT (plan_id) DO UPDATE
SET assignment_id=EXCLUDED.assignment_id, plan_tasks=EXCLUDED.plan_tasks, fact_tasks=EXCLUDED.fact_tasks,
    start_date=EXCLUDED.start_date, end_date=EXCLUDED.end_date, load_date=clock_timestamp(), record_source=EXCLUDED.record_source;

-- 7. Индивидуальная история зарплат. Базовые уровни, повышения, понижения, неизменная зарплата и карантин от 0 до> 40000
WITH src (snils,post_id,assignment_start,effective_from,salary,reason_id) AS (
    VALUES
        ('TEST-000000001', 101, DATE '2024-02-01', DATE '2024-02-01', 110000, 9),
        ('TEST-000000001', 101, DATE '2024-02-01', DATE '2025-05-01', 116000, 7),
        ('TEST-000000001', 101, DATE '2024-02-01', DATE '2025-12-01', 124000, 8),
        ('TEST-000000002', 106, DATE '2025-04-01', DATE '2025-04-01', 46000, 9),
        ('TEST-000000002', 106, DATE '2025-04-01', DATE '2025-11-17', 53600, 7),
        ('TEST-000000003', 101, DATE '2024-02-01', DATE '2024-02-01', 52000, 9),
        ('TEST-000000003', 101, DATE '2024-02-01', DATE '2024-10-01', 61000, 7),
        ('TEST-000000003', 103, DATE '2025-02-15', DATE '2025-02-15', 75000, 9),
        ('TEST-000000003', 103, DATE '2025-02-15', DATE '2025-10-01', 84000, 8),
        ('TEST-000000003', 103, DATE '2025-02-15', DATE '2026-04-01', 98000, 9),
        ('TEST-000000004', 105, DATE '2025-06-01', DATE '2025-06-01', 65000, 9),
        ('TEST-000000005', 104, DATE '2024-08-01', DATE '2024-08-01', 65000, 9),
        ('TEST-000000005', 104, DATE '2024-08-01', DATE '2025-03-19', 69000, 7),
        ('TEST-000000005', 104, DATE '2024-08-01', DATE '2025-09-25', 77500, 8),
        ('TEST-000000006', 108, DATE '2025-01-20', DATE '2025-01-20', 107500, 9),
        ('TEST-000000006', 108, DATE '2025-01-20', DATE '2025-07-19', 100500, 12),
        ('TEST-000000007', 109, DATE '2024-02-01', DATE '2024-02-01', 155000, 9),
        ('TEST-000000007', 109, DATE '2024-02-01', DATE '2024-08-24', 162600, 7),
        ('TEST-000000008', 106, DATE '2024-02-01', DATE '2024-02-01', 48500, 9),
        ('TEST-000000008', 106, DATE '2024-02-01', DATE '2024-09-18', 57900, 7),
        ('TEST-000000008', 110, DATE '2025-06-01', DATE '2025-06-01', 67500, 9),
        ('TEST-000000008', 110, DATE '2025-06-01', DATE '2026-01-17', 76900, 7),
        ('TEST-000000009', 102, DATE '2023-09-01', DATE '2023-09-01', 135000, 9),
        ('TEST-000000009', 102, DATE '2023-09-01', DATE '2024-02-28', 146200, 7),
        ('TEST-000000009', 102, DATE '2023-09-01', DATE '2024-09-05', 147500, 8),
        ('TEST-000000010', 111, DATE '2024-11-01', DATE '2024-11-01', 95000, 9),
        ('TEST-000000010', 111, DATE '2024-11-01', DATE '2025-08-01', 90000, 12),
        ('TEST-000000010', 111, DATE '2024-11-01', DATE '2026-02-01', 97000, 9),
        ('TEST-000000011', 101, DATE '2025-09-01', DATE '2025-09-01', 62500, 9),
        ('TEST-000000012', 101, DATE '2024-07-01', DATE '2024-07-01', 65000, 9),
        ('TEST-000000012', 101, DATE '2024-07-01', DATE '2024-12-28', 72600, 7),
        ('TEST-000000012', 112, DATE '2025-03-01', DATE '2025-03-01', 55000, 9),
        ('TEST-000000012', 112, DATE '2025-03-01', DATE '2025-09-01', 60000, 7),
        ('TEST-000000012', 112, DATE '2025-03-01', DATE '2026-03-01', 67000, 8),
        ('TEST-000000013', 107, DATE '2024-07-01', DATE '2024-07-01', 162500, 9),
        ('TEST-000000013', 107, DATE '2024-07-01', DATE '2025-01-22', 171900, 7),
        ('TEST-000000014', 106, DATE '2025-01-01', DATE '2025-01-01', 60000, 9),
        ('TEST-000000015', 103, DATE '2024-04-01', DATE '2024-04-01', 135000, 9),
        ('TEST-000000015', 103, DATE '2024-04-01', DATE '2024-09-28', 139000, 7),
        ('TEST-000000015', 103, DATE '2024-04-01', DATE '2025-04-06', 147500, 8),
        ('TEST-000000016', 105, DATE '2025-12-01', DATE '2025-12-01', 57500, 9),
        ('TEST-000000016', 105, DATE '2025-12-01', DATE '2026-06-24', 63300, 7),
        ('TEST-000000017', 105, DATE '2024-01-01', DATE '2024-01-01', 60000, 9),
        ('TEST-000000017', 105, DATE '2024-01-01', DATE '2024-08-18', 67600, 7),
        ('TEST-000000017', 104, DATE '2025-04-15', DATE '2025-04-15', 70000, 9),
        ('TEST-000000017', 104, DATE '2025-04-15', DATE '2025-12-01', 77600, 7),
        ('TEST-000000018', 108, DATE '2024-10-01', DATE '2024-10-01', 112500, 9),
        ('TEST-000000018', 108, DATE '2024-10-01', DATE '2025-03-30', 105500, 12),
        ('TEST-000000019', 109, DATE '2024-03-01', DATE '2024-03-01', 160000, 9),
        ('TEST-000000019', 109, DATE '2024-03-01', DATE '2024-09-22', 171200, 7),
        ('TEST-000000020', 110, DATE '2025-01-01', DATE '2025-01-01', 60000, 9),
        ('TEST-000000020', 110, DATE '2025-01-01', DATE '2025-08-19', 64000, 7),
        ('TEST-000000021', 111, DATE '2025-03-20', DATE '2025-03-20', 94500, 9),
        ('TEST-000000021', 111, DATE '2025-03-20', DATE '2025-09-01', 94500, 7),
        ('TEST-000000021', 111, DATE '2025-03-20', DATE '2026-05-01', 101500, 8),
        ('TEST-000000022', 112, DATE '2024-05-01', DATE '2024-05-01', 88000, 9),
        ('TEST-000000022', 112, DATE '2024-05-01', DATE '2024-11-22', 95600, 7),
        ('TEST-000000022', 112, DATE '2024-05-01', DATE '2025-05-31', 100500, 8),
        ('TEST-000000023', 102, DATE '2025-03-01', DATE '2025-03-01', 132500, 9),
        ('TEST-000000023', 102, DATE '2025-03-01', DATE '2025-10-17', 141900, 7),
        ('TEST-000000023', 102, DATE '2025-03-01', DATE '2026-04-25', 145000, 8),
        ('TEST-000000024', 101, DATE '2025-01-10', DATE '2025-01-10', 70000, 9),
        ('TEST-000000024', 101, DATE '2025-01-10', DATE '2025-07-09', 81200, 7),
        ('TEST-000000025', 106, DATE '2025-10-01', DATE '2025-10-01', 0, NULL),
        ('TEST-000000025', 106, DATE '2025-10-01', DATE '2026-03-01', 40000, 9),
        ('TEST-000000026', 103, DATE '2025-06-01', DATE '2025-06-01', 137500, 9),
        ('TEST-000000026', 103, DATE '2025-06-01', DATE '2026-01-17', 143300, 7),
        ('TEST-000000026', 103, DATE '2025-06-01', DATE '2026-07-26', 150000, 8),
        ('TEST-000000027', 105, DATE '2026-01-01', DATE '2026-01-01', 60000, 9),
        ('TEST-000000027', 105, DATE '2026-01-01', DATE '2026-06-30', 67600, 7),
        ('TEST-000000028', 107, DATE '2024-12-01', DATE '2024-12-01', 162500, 9),
        ('TEST-000000028', 107, DATE '2024-12-01', DATE '2025-06-24', 171900, 7),
        ('TEST-000000030', 110, DATE '2025-10-01', DATE '2025-10-01', 60000, 9)
)
INSERT INTO public.employee_salary_history (assignment_id,salary,effective_from,load_date,reason_id)
SELECT s.assignment_id, v.salary, v.effective_from, clock_timestamp(), v.reason_id
FROM src v JOIN public.staffing_table s
 ON s.snils=v.snils AND s.post_id=v.post_id AND s.start_date=v.assignment_start
WHERE true
ON CONFLICT (assignment_id,effective_from) DO UPDATE
SET salary=EXCLUDED.salary, reason_id=EXCLUDED.reason_id, load_date=clock_timestamp();

-- 8. Необязательная промежуточная обработка в формате RAW. Эти таблицы предназначены только для диагностики
DELETE FROM public.stg_staffing_table WHERE batch_id='demo-2026-10';
DELETE FROM public.stg_reason_information WHERE batch_id='demo-2026-10';
DELETE FROM public.stg_people WHERE batch_id='demo-2026-10';
INSERT INTO public.stg_people (batch_id,snils) VALUES
    ('demo-2026-10','TEST-000000001'),
    ('demo-2026-10','TEST-000000001'),
    ('demo-2026-10','TEST-000000011'),
    ('demo-2026-10','TEST-999999998');
INSERT INTO public.stg_reason_information (batch_id,reason_id,reason_type,reason) VALUES
    ('demo-2026-10', 1, 'dismissal', ARRAY['По собственному желанию']::text[]),
    ('demo-2026-10', 2, 'dismissal', ARRAY['Переезд']::text[]),
    ('demo-2026-10', 3, 'dismissal', NULL),
    ('demo-2026-10', 4, 'dismissal', ARRAY[]::text[]),
    ('demo-2026-10', 5, 'dismissal', ARRAY['']::text[]),
    ('demo-2026-10', 6, 'dismissal', ARRAY['Семейные обстоятельства']::text[]),
    ('demo-2026-10', 888, 'dismissal', ARRAY['Новая причина в той же партии']::text[]);
INSERT INTO public.stg_staffing_table (batch_id,snils,post_id,reason_id,start_date,end_date,load_date) VALUES
    ('demo-2026-10', 'TEST-000000001', 101, 4, DATE '2024-02-01', DATE '2026-02-15', clock_timestamp()),
    ('demo-2026-10', 'TEST-999999999', 101, 1, DATE '2026-06-01', NULL, clock_timestamp()),
    ('demo-2026-10', 'TEST-000000005', 999, 1, DATE '2026-06-01', NULL, clock_timestamp()),
    ('demo-2026-10', 'TEST-000000006', 108, 999, DATE '2026-06-01', NULL, clock_timestamp()),
    ('demo-2026-10', 'TEST-999999998', 101, NULL, DATE '2026-09-01', NULL, clock_timestamp()),
    ('demo-2026-10', 'TEST-000000007', 109, 888, DATE '2026-09-01', NULL, clock_timestamp()),
    ('demo-2026-10', 'TEST-000000008', 110, 2, DATE '2026-09-01', DATE '2026-08-01', clock_timestamp());

DO $$
BEGIN
    IF (SELECT count(*) FROM public.staffing_table WHERE snils LIKE 'TEST-%') <> 34 THEN
        RAISE EXCEPTION 'Expected demo staffing assignments not found';
    END IF;
    IF (SELECT count(*) FROM public.plan_execution WHERE plan_id BETWEEN 5001 AND 5037) <> 37 THEN
        RAISE EXCEPTION 'Not all demo plans were inserted';
    END IF;
    IF (SELECT count(*) FROM public.employee_salary_history esh JOIN public.staffing_table st ON st.assignment_id=esh.assignment_id WHERE st.snils LIKE 'TEST-%') <> 73 THEN
        RAISE EXCEPTION 'Not all demo salary events were inserted';
    END IF;
END;
$$;

COMMIT;