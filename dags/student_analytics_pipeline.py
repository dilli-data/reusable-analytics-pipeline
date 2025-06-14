from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'student_analytics_pipeline',
    default_args=default_args,
    description='ETL pipeline for student analytics',
    schedule_interval='@daily',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['education', 'analytics'],
)

# Check for new data in S3
check_sis_data = S3KeySensor(
    task_id='check_sis_data',
    bucket_key='raw/sis/*.csv',
    bucket_name='education-data-lake',
    aws_conn_id='aws_default',
    dag=dag,
)

# Process SIS data using Glue
process_sis_data = GlueJobOperator(
    task_id='process_sis_data',
    job_name='process_sis_data',
    aws_conn_id='aws_default',
    region_name='us-east-1',
    dag=dag,
)

# Transform data in Snowflake
transform_data = SnowflakeOperator(
    task_id='transform_data',
    sql='sql/transform_student_data.sql',
    snowflake_conn_id='snowflake_default',
    dag=dag,
)

# Run data quality checks
run_quality_checks = SnowflakeOperator(
    task_id='run_quality_checks',
    sql='sql/quality_checks.sql',
    snowflake_conn_id='snowflake_default',
    dag=dag,
)

# Update analytics models
update_analytics = SnowflakeOperator(
    task_id='update_analytics',
    sql='sql/update_analytics_models.sql',
    snowflake_conn_id='snowflake_default',
    dag=dag,
)

# Set task dependencies
check_sis_data >> process_sis_data >> transform_data >> run_quality_checks >> update_analytics 