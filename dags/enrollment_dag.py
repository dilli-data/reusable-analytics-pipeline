from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

def extract():
    print("Extracting student data from S3...")

def transform():
    print("Transforming data using PySpark...")

def load():
    print("Loading data into Snowflake...")

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

with DAG('enrollment_etl_dag', default_args=default_args, schedule_interval='@daily', catchup=False) as dag:
    extract_task = PythonOperator(task_id='extract', python_callable=extract)
    transform_task = PythonOperator(task_id='transform', python_callable=transform)
    load_task = PythonOperator(task_id='load', python_callable=load)

    extract_task >> transform_task >> load_task
