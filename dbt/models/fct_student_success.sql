SELECT
    student_id,
    term,
    ROUND(AVG(gpa), 2) AS avg_gpa,
    SUM(credits) AS total_credits,
    COUNT(*) AS term_count
FROM {{ ref('stg_enrollment') }}
GROUP BY student_id, term
