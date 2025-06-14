resource "snowflake_warehouse" "edu_warehouse" {
  name         = "EDU_WH"
  size         = "XSMALL"
  auto_suspend = 60
  auto_resume  = true
}

resource "snowflake_database" "edu_db" {
  name = "EDU_ANALYTICS"
}

resource "snowflake_schema" "student_schema" {
  name     = "STUDENT_DATA"
  database = snowflake_database.edu_db.name
}
