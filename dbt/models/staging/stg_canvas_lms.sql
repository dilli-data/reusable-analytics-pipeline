{{
    config(
        materialized='view',
        schema='staging'
    )
}}

WITH canvas_users AS (
    SELECT
        id as canvas_user_id,
        sis_user_id as student_id,
        name as full_name,
        sortable_name as sortable_name,
        short_name as short_name,
        sis_import_id as sis_import_id,
        integration_id as integration_id,
        login_id as login_id,
        email as email,
        current_timestamp as dbt_updated_at
    FROM {{ source('canvas', 'users') }}
),

canvas_courses AS (
    SELECT
        id as canvas_course_id,
        sis_course_id as sis_course_id,
        name as course_name,
        course_code as course_code,
        sis_import_id as sis_import_id,
        integration_id as integration_id,
        current_timestamp as dbt_updated_at
    FROM {{ source('canvas', 'courses') }}
),

canvas_enrollments AS (
    SELECT
        id as enrollment_id,
        user_id as canvas_user_id,
        course_id as canvas_course_id,
        type as enrollment_type,
        role as role,
        role_id as role_id,
        sis_import_id as sis_import_id,
        current_timestamp as dbt_updated_at
    FROM {{ source('canvas', 'enrollments') }}
),

canvas_assignments AS (
    SELECT
        id as assignment_id,
        course_id as canvas_course_id,
        name as assignment_name,
        description as description,
        due_at as due_date,
        points_possible as points_possible,
        current_timestamp as dbt_updated_at
    FROM {{ source('canvas', 'assignments') }}
),

canvas_submissions AS (
    SELECT
        id as submission_id,
        assignment_id as assignment_id,
        user_id as canvas_user_id,
        score as score,
        grade as grade,
        submitted_at as submitted_date,
        current_timestamp as dbt_updated_at
    FROM {{ source('canvas', 'submissions') }}
)

SELECT
    u.*,
    c.canvas_course_id,
    c.course_name,
    c.course_code,
    e.enrollment_type,
    e.role,
    a.assignment_id,
    a.assignment_name,
    a.points_possible,
    s.score,
    s.grade,
    s.submitted_date
FROM canvas_users u
LEFT JOIN canvas_enrollments e
    ON u.canvas_user_id = e.canvas_user_id
LEFT JOIN canvas_courses c
    ON e.canvas_course_id = c.canvas_course_id
LEFT JOIN canvas_assignments a
    ON c.canvas_course_id = a.canvas_course_id
LEFT JOIN canvas_submissions s
    ON a.assignment_id = s.assignment_id
    AND u.canvas_user_id = s.canvas_user_id 