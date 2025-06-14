{{
    config(
        materialized='table',
        schema='analytics'
    )
}}

WITH campus_solutions AS (
    SELECT * FROM {{ ref('stg_ps_campus_solutions') }}
),

hr_data AS (
    SELECT * FROM {{ ref('stg_ps_hr') }}
),

financial_aid AS (
    SELECT * FROM {{ ref('stg_ps_financial_aid') }}
),

canvas_lms AS (
    SELECT * FROM {{ ref('stg_canvas_lms') }}
)

SELECT
    -- Student Information
    cs.student_id,
    cs.academic_career,
    cs.student_career_number,
    cs.academic_program,
    cs.program_status,
    cs.admit_term,
    cs.exp_grad_term,
    cs.academic_load,
    cs.tuit_res,
    cs.acad_level_proj as projected_academic_level,
    
    -- Academic Plan
    cs.academic_plan,
    cs.plan_status,
    
    -- Course Information
    cs.term_id,
    cs.class_number,
    cs.course_id,
    cs.enrollment_status,
    cs.enrollment_date,
    cs.drop_date,
    cs.grade_points,
    cs.grade,
    
    -- HR/Advisor Information
    hr.employee_id as advisor_id,
    hr.full_name as advisor_name,
    hr.department_id as advisor_department,
    hr.job_code as advisor_job_code,
    
    -- Financial Aid Information
    fa.aid_year,
    fa.item_type as aid_type,
    fa.packaging_status,
    fa.packaging_date,
    fa.aid_status,
    fa.amount,
    fa.disbursement_date,
    fa.disbursement_status,
    fa.term_status as financial_aid_term_status,
    
    -- Canvas LMS Information
    cl.canvas_user_id,
    cl.course_name as canvas_course_name,
    cl.course_code as canvas_course_code,
    cl.enrollment_type as canvas_enrollment_type,
    cl.role as canvas_role,
    cl.assignment_name,
    cl.points_possible,
    cl.score as assignment_score,
    cl.grade as assignment_grade,
    cl.submitted_date as assignment_submitted_date,
    
    -- Calculated Fields
    CASE
        WHEN cs.grade >= 3.0 THEN 'Good Standing'
        WHEN cs.grade >= 2.0 THEN 'Warning'
        ELSE 'Probation'
    END as academic_standing,
    
    CASE
        WHEN LEAD(cs.term_id) OVER (PARTITION BY cs.student_id ORDER BY cs.term_id) IS NOT NULL THEN 'Retained'
        ELSE 'Not Retained'
    END as retention_status,
    
    CASE
        WHEN cl.submitted_date IS NOT NULL THEN 'Submitted'
        WHEN cl.due_date < CURRENT_TIMESTAMP THEN 'Late'
        ELSE 'Not Submitted'
    END as assignment_status,
    
    -- Timestamps
    cs.dbt_updated_at as campus_solutions_updated_at,
    hr.dbt_updated_at as hr_updated_at,
    fa.dbt_updated_at as financial_aid_updated_at,
    cl.dbt_updated_at as canvas_updated_at,
    CURRENT_TIMESTAMP as dbt_updated_at

FROM campus_solutions cs
LEFT JOIN hr_data hr
    ON cs.student_id = hr.employee_id
LEFT JOIN financial_aid fa
    ON cs.student_id = fa.student_id
    AND cs.term_id = fa.term_id
LEFT JOIN canvas_lms cl
    ON cs.student_id = cl.student_id
    AND cs.course_id = cl.sis_course_id 