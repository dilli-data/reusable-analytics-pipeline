WITH source AS (
    SELECT * FROM {{ source('raw', 'enrollment') }}
)

SELECT
    CAST(student_id AS STRING) AS student_id,
    term,
    CAST(gpa AS FLOAT) AS gpa,
    CAST(credits AS INT) AS credits
FROM source
