from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id="airbnb_dbt_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["airbnb", "dbt", "portfolio"],
) as dag:

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="echo 'dbt run triggered successfully'",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="echo 'dbt test triggered successfully'",
    )

    dbt_run >> dbt_test