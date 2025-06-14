{{
    config(
        materialized='table',
        schema='analytics'
    )
}}

WITH student_enrollment AS (
    SELECT
        student_id,
        term_id,
        enrollment_status,
        enrollment_date,
        course_id,
        grade
    FROM {{ ref('stg_student_enrollment') }}
),

student_demographics AS (
    SELECT
        student_id,
        first_name,
        last_name,
        date_of_birth,
        gender,
        ethnicity,
        first_generation_status
    FROM {{ ref('stg_student_demographics') }}
),

financial_aid AS (
    SELECT
        student_id,
        term_id,
        aid_type,
        amount_awarded,
        disbursement_date
    FROM {{ ref('stg_financial_aid') }}
),

course_info AS (
    SELECT
        course_id,
        course_name,
        department,
        credits,
        instructor_id
    FROM {{ ref('stg_course_info') }}
)

SELECT
    se.student_id,
    sd.first_name,
    sd.last_name,
    sd.gender,
    sd.ethnicity,
    sd.first_generation_status,
    se.term_id,
    se.enrollment_status,
    se.enrollment_date,
    ci.course_name,
    ci.department,
    ci.credits,
    se.grade,
    fa.aid_type,
    fa.amount_awarded,
    fa.disbursement_date,
    -- Calculate academic standing
    CASE
        WHEN se.grade >= 3.0 THEN 'Good Standing'
        WHEN se.grade >= 2.0 THEN 'Warning'
        ELSE 'Probation'
    END as academic_standing,
    -- Calculate retention status
    CASE
        WHEN LEAD(se.term_id) OVER (PARTITION BY se.student_id ORDER BY se.term_id) IS NOT NULL THEN 'Retained'
        ELSE 'Not Retained'
    END as retention_status
FROM student_enrollment se
LEFT JOIN student_demographics sd
    ON se.student_id = sd.student_id
LEFT JOIN course_info ci
    ON se.course_id = ci.course_id
LEFT JOIN financial_aid fa
    ON se.student_id = fa.student_id
    AND se.term_id = fa.term_id 