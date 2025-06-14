{{
    config(
        materialized='view',
        schema='staging'
    )
}}

WITH ps_financial_aid AS (
    SELECT
        emplid as student_id,
        aid_year as aid_year,
        item_type as item_type,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        packaging_status as packaging_status,
        packaging_dt as packaging_date,
        aid_status as aid_status,
        aid_status_dt as status_date,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_financial_aid') }}
),

ps_financial_aid_item AS (
    SELECT
        emplid as student_id,
        aid_year as aid_year,
        item_type as item_type,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        amount as amount,
        disb_dt as disbursement_date,
        disb_status as disbursement_status,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_financial_aid_item') }}
),

ps_financial_aid_term AS (
    SELECT
        emplid as student_id,
        aid_year as aid_year,
        term_id as term_id,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        term_status as term_status,
        term_status_dt as status_date,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_financial_aid_term') }}
)

SELECT
    f.*,
    i.amount,
    i.disbursement_date,
    i.disbursement_status,
    t.term_id,
    t.term_status,
    t.status_date as term_status_date
FROM ps_financial_aid f
LEFT JOIN ps_financial_aid_item i
    ON f.student_id = i.student_id
    AND f.aid_year = i.aid_year
    AND f.item_type = i.item_type
    AND f.academic_career = i.academic_career
    AND f.student_career_number = i.student_career_number
LEFT JOIN ps_financial_aid_term t
    ON f.student_id = t.student_id
    AND f.aid_year = t.aid_year
    AND f.academic_career = t.academic_career
    AND f.student_career_number = t.student_career_number 