-- 01_schema.sql
-- PostgreSQL 14+. Запустите один раз в НОВОЙ, ПУСТОЙ базе данных/схеме (public).
-- Скрипт создает исходные справочные таблицы и таблицы фактов, две витрины данных, DQ, метаданные карантина и ETL.


BEGIN;

-- =============================================================
-- Справочные таблицы
-- =============================================================
CREATE TABLE IF NOT EXISTS public.people (
    snils varchar(14) PRIMARY KEY,
    surname varchar(30) NOT NULL,
    name varchar(30) NOT NULL,
    middle_name varchar(30),
    birth_date date NOT NULL,
    gender varchar(10) NOT NULL,
    education_level  varchar(30) NOT NULL,
    city varchar(30) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    status varchar(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.post_information (
    post_id integer PRIMARY KEY,
    structural_division varchar(30) NOT NULL,
    post_name varchar(30) NOT NULL,
    position_count integer NOT NULL CHECK (position_count >= 0),
    skills varchar(200),
    start_date date NOT NULL,
    end_date date,
    status varchar(10) NOT NULL,
    CONSTRAINT chk_post_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS public.reason_information (
    reason_id integer PRIMARY KEY,
    reason_type varchar(30) NOT NULL,
    reason text[] NOT NULL,
    CONSTRAINT chk_reason_nonempty CHECK (
        cardinality(reason) > 0 AND array_position(reason, NULL) IS NULL
    )
);

-- =============================================================
-- Таблицы факты
-- =============================================================
CREATE TABLE IF NOT EXISTS public.post_salary (
    post_id integer NOT NULL REFERENCES public.post_information(post_id),
    salary numeric(12,2) NOT NULL CHECK (salary >= 0),
    start_date date NOT NULL,
    end_date date,
    load_date timestamp NOT NULL,
    PRIMARY KEY (post_id, load_date),
    CONSTRAINT chk_post_salary_dates CHECK (end_date IS NULL OR end_date >= start_date)
);
-- post_salary описывает ЗП за должность (не оклад сотрудника)

CREATE TABLE IF NOT EXISTS public.staffing_table (
    assignment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    snils varchar(14) NOT NULL REFERENCES public.people(snils),
    post_id integer NOT NULL REFERENCES public.post_information(post_id),
    reason_id integer REFERENCES public.reason_information(reason_id),
    start_date date NOT NULL,
    end_date date,
    load_date timestamp NOT NULL,
    CONSTRAINT uq_staffing_assignment UNIQUE (snils, post_id, start_date)
);


CREATE TABLE IF NOT EXISTS public.plan_execution (
    plan_id  bigint PRIMARY KEY,
    assignment_id bigint NOT NULL REFERENCES public.staffing_table(assignment_id),
    plan_tasks integer NOT NULL CHECK (plan_tasks >= 0),
    fact_tasks integer CHECK (fact_tasks IS NULL OR fact_tasks >= 0),
    start_date date NOT NULL,
    end_date date,
    load_date timestamp NOT NULL,
    record_source varchar(120) NOT NULL,
    CONSTRAINT chk_plan_execution_dates CHECK (end_date IS NULL OR end_date >= start_date)
);
-- plan_execution ссылается на конкретное штатное расписание, а не на тройку (post_id, snils, reason_id), которая может соответствовать нескольким расписаниям.

CREATE TABLE IF NOT EXISTS public.employee_salary_history (
    salary_event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    assignment_id bigint NOT NULL REFERENCES public.staffing_table(assignment_id),
    salary numeric(12,2) NOT NULL CHECK (salary >= 0),
    effective_from date NOT NULL,
    load_date timestamp NOT NULL,
    reason_id integer REFERENCES public.reason_information(reason_id),
    CONSTRAINT uq_employee_salary_date UNIQUE (assignment_id, effective_from)
);

-- =============================================================
-- Промежуточные таблицы
-- =============================================================
CREATE TABLE IF NOT EXISTS public.stg_people (
    source_row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    batch_id text NOT NULL DEFAULT 'default',
    snils varchar(14),
    received_at timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE IF NOT EXISTS public.stg_reason_information (
    source_row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    batch_id text NOT NULL DEFAULT 'default',
    reason_id integer,
    reason_type varchar(30),
    reason text[],
    received_at timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE IF NOT EXISTS public.stg_staffing_table (
    source_row_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    batch_id text NOT NULL DEFAULT 'default',
    snils varchar(14),
    post_id integer,
    reason_id integer,
    start_date date,
    end_date date,
    load_date timestamp,
    received_at timestamp NOT NULL DEFAULT clock_timestamp()
);

-- =============================================================
-- Витрины
-- =============================================================
CREATE TABLE IF NOT EXISTS public.turnover (
    assignment_id bigint PRIMARY KEY REFERENCES public.staffing_table(assignment_id),
    snils varchar(14) NOT NULL,
    end_date date NOT NULL,
    reason_for_leaving text[],
    working_period integer NOT NULL CHECK (working_period >= 0),
    load_date timestamp NOT NULL
);


CREATE TABLE IF NOT EXISTS public.salary_change (
    salary_event_id bigint PRIMARY KEY REFERENCES public.employee_salary_history(salary_event_id),
    assignment_id bigint NOT NULL REFERENCES public.staffing_table(assignment_id),
    snils varchar(14) NOT NULL,
    salary_change_percent numeric(20,2) NOT NULL,
    previous_salary numeric(12,2) NOT NULL,
    current_salary numeric(12,2) NOT NULL,
    post_name text NOT NULL,
    grade text NOT NULL,
    reason_salary_change text,
    effective_from date NOT NULL,
    load_date timestamp NOT NULL
);

-- =============================================================
-- Карантин
-- =============================================================
CREATE TABLE IF NOT EXISTS public.turnover_rejected (
    assignment_id bigint PRIMARY KEY REFERENCES public.staffing_table(assignment_id),
    snils varchar(14) NOT NULL,
    end_date date NOT NULL,
    reason_for_leaving text[],
    working_period integer,
    load_date timestamp NOT NULL,
    rejection_check text NOT NULL,
    rejection_reason text NOT NULL,
    rejected_at timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE TABLE IF NOT EXISTS public.salary_change_rejected (
    salary_event_id bigint PRIMARY KEY REFERENCES public.employee_salary_history(salary_event_id),
    assignment_id bigint NOT NULL REFERENCES public.staffing_table(assignment_id),
    snils varchar(14) NOT NULL,
    salary_change_percent numeric(20,2),
    previous_salary numeric(12,2),
    current_salary numeric(12,2),
    post_name text,
    grade text,
    reason_salary_change text,
    effective_from date NOT NULL,
    load_date timestamp NOT NULL,
    rejection_check text NOT NULL,
    rejection_reason text NOT NULL,
    rejected_at timestamp NOT NULL DEFAULT clock_timestamp()
);
-- Карантин — это текущий статус отклонения. Исправленное событие удаляется из карантина с помощью ETL; 
-- результаты предыдущих проверок хранятся в dq_issue.

-- =============================================================
-- ETL/ история DQ
-- =============================================================
CREATE TABLE IF NOT EXISTS public.etl_watermark (
    process_name text PRIMARY KEY,
    last_load_ts timestamp NOT NULL DEFAULT timestamp '1900-01-01'
);

CREATE TABLE IF NOT EXISTS public.etl_run (
    run_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    started_at timestamp NOT NULL DEFAULT clock_timestamp(),
    finished_at timestamp,
    status text NOT NULL DEFAULT 'RUNNING'
    CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED'))
);

CREATE TABLE IF NOT EXISTS public.dq_issue (
    issue_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    run_id bigint NOT NULL REFERENCES public.etl_run(run_id),
    check_code text NOT NULL,
    severity text NOT NULL CHECK (severity IN ('WARNING', 'CRITICAL')),
    entity text NOT NULL,
    row_key text,
    message_txt text,
    detected_at timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS ix_staffing_load ON public.staffing_table(load_date);
CREATE INDEX IF NOT EXISTS ix_salary_history_load ON public.employee_salary_history(load_date);
CREATE INDEX IF NOT EXISTS ix_salary_history_assignment_date
    ON public.employee_salary_history(assignment_id, effective_from, salary_event_id);
CREATE INDEX IF NOT EXISTS ix_plan_execution_load ON public.plan_execution(load_date);
CREATE INDEX IF NOT EXISTS ix_plan_execution_assignment_dates
    ON public.plan_execution(assignment_id, start_date DESC, load_date DESC);
CREATE INDEX IF NOT EXISTS ix_dq_issue_run_code ON public.dq_issue(run_id, check_code);
CREATE INDEX IF NOT EXISTS ix_turnover_end_date ON public.turnover(end_date);
CREATE INDEX IF NOT EXISTS ix_salary_change_effective_from ON public.salary_change(effective_from);

COMMIT;