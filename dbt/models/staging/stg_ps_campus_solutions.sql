{{
    config(
        materialized='view',
        schema='staging'
    )
}}

WITH ps_student AS (
    SELECT
        emplid as student_id,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        adm_recr_ctr as admission_center,
        effdt as effective_date,
        effseq as effective_sequence,
        stdnt_car_stat as student_career_status,
        stdnt_car_stat_dt as status_date,
        acad_prog as academic_program,
        prog_status as program_status,
        prog_action as program_action,
        prog_reason as program_reason,
        prog_action_dt as action_date,
        admit_term as admit_term,
        exp_grad_term as expected_graduation_term,
        acad_load_appr as academic_load,
        tuit_res as tuition_residency,
        acad_level_proj as projected_academic_level,
        acad_level_bot as beginning_of_term_academic_level,
        acad_level_eot as end_of_term_academic_level,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_stdnt_car_term') }}
),

ps_academic_plan AS (
    SELECT
        emplid as student_id,
        acad_career as academic_career,
        stdnt_car_nbr as student_career_number,
        effdt as effective_date,
        effseq as effective_sequence,
        acad_plan as academic_plan,
        plan_status as plan_status,
        plan_action as plan_action,
        plan_reason as plan_reason,
        plan_action_dt as action_date,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_acad_plan') }}
),

ps_course_enrollment AS (
    SELECT
        emplid as student_id,
        strm as term_id,
        class_nbr as class_number,
        crse_id as course_id,
        crse_offer_nbr as course_offer_number,
        enrl_status as enrollment_status,
        enrl_add_dt as enrollment_date,
        enrl_drop_dt as drop_date,
        grade_points as grade_points,
        grade as grade,
        current_timestamp as dbt_updated_at
    FROM {{ source('peoplesoft', 'ps_stdnt_enrl') }}
)

SELECT
    s.*,
    p.academic_plan,
    p.plan_status,
    e.term_id,
    e.class_number,
    e.course_id,
    e.enrollment_status,
    e.enrollment_date,
    e.drop_date,
    e.grade_points,
    e.grade
FROM ps_student s
LEFT JOIN ps_academic_plan p
    ON s.student_id = p.student_id
    AND s.academic_career = p.academic_career
    AND s.student_career_number = p.student_career_number
LEFT JOIN ps_course_enrollment e
    ON s.student_id = e.student_id 