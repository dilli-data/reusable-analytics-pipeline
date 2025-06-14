{{
    config(
        materialized='view',
        schema='staging'
    )
}}

WITH ps_personal_data AS (
    SELECT
        emplid as employee_id,
        name as full_name,
        last_name,
        first_name,
        middle_name,
        name_prefix as prefix,
        name_suffix as suffix,
        name_type as name_type,
        effdt as effective_date,
        effseq as effective_sequence,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_personal_data') }}
),

ps_job AS (
    SELECT
        emplid as employee_id,
        effdt as effective_date,
        effseq as effective_sequence,
        empl_rcd as employment_record,
        jobcode as job_code,
        deptid as department_id,
        position_nbr as position_number,
        job_entry_dt as job_entry_date,
        job_terminated as is_terminated,
        job_termination_dt as termination_date,
        job_action as job_action,
        job_reason as job_reason,
        job_action_dt as action_date,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_job') }}
),

ps_academic_advisor AS (
    SELECT
        emplid as employee_id,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        advisor_type as advisor_type,
        advisor_id as advisor_id,
        effdt as effective_date,
        effseq as effective_sequence,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_acad_advisor') }}
)

SELECT
    p.*,
    j.job_code,
    j.department_id,
    j.position_number,
    j.job_entry_date,
    j.is_terminated,
    j.termination_date,
    j.job_action,
    j.job_reason,
    a.academic_career,
    a.advisor_type,
    a.advisor_id
FROM ps_personal_data p
LEFT JOIN ps_job j
    ON p.employee_id = j.employee_id
LEFT JOIN ps_academic_advisor a
    ON p.employee_id = a.employee_id 