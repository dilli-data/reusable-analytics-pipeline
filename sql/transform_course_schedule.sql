-- Transform raw course schedule data
SELECT
    course_id,
    department,
    faculty_id,
    term,
    schedule_day,
    capacity,
    enrolled_students,
    capacity - enrolled_students AS seats_remaining
FROM raw.course_schedule
WHERE term IS NOT NULL
