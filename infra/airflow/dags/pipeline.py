import os
from docker.types import Mount
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.models import Variable
from datetime import timedelta, datetime

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
    'max_retry_delay': timedelta(minutes=30),
}

dag = DAG(
    'rankalpha_pipeline',
    default_args=default_args,
    description='Daily RankAlpha data pipeline with ingestion, scoring, AI analysis, and frontend update',
    schedule='0 6 * * *',  # Run daily at 6 AM
    start_date=days_ago(1),
    catchup=False,
    max_active_runs=1,  # Ensure only one instance runs at a time
)

# Environment profile selection: prefer Airflow Variable, fall back to container env, then 'local'
ENV_PROFILE = Variable.get("ENV_PROFILE", default_var=os.environ.get("RANKALPHA_ENV", "local"))
INGESTION_ENV_PATH = f"/opt/rankalpha/env/{ENV_PROFILE}/ingestion.env"
SENTIMENT_ENV_PATH = f"/opt/rankalpha/env/{ENV_PROFILE}/sentiment.env"
PRICES_DATA_HOST = "prices_data"

def load_env_vars(env_file):
    try:
        out = {}
        with open(env_file) as f:
            for raw in f:
                line = raw.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' not in line:
                    continue
                key, val = line.split('=', 1)
                key = key.strip()
                val = val.strip().strip('"').strip("'")
                out[key] = val
        return out
    except FileNotFoundError:
        print(f"[WARNING] Missing env file: {env_file}")
        return {}

def merge_env(base: dict, names: list[str]) -> dict:
    """Return a copy of base with values overridden by Airflow Variables when present.

    For each env var name in names, take Variable.get(name) if defined, otherwise keep base[name].
    """
    merged = dict(base)
    for n in names:
        try:
            v = Variable.get(n, default_var=base.get(n))
        except Exception:
            v = base.get(n)
        if v is not None:
            merged[n] = v
    return merged

ingestion = DockerOperator(
    task_id='run_ingestion',
    image='rankalpha_ingestion',
    api_version='auto',
    auto_remove='success',
    command='python apps/ingestion/main.py',
    docker_url='unix://var/run/docker.sock',
    network_mode='rankalpha_net',
    do_xcom_push=False,
    cpus=float(Variable.get('INGESTION_CPUS', default_var='1.0')),
    mem_limit=Variable.get('INGESTION_MEM', default_var='1g'),
    environment=(lambda base: {
        **merge_env(
            base,
            [
                # optional DB overrides
                'DB_USERNAME','PASSWORD','HOST','PORT','DATABASE_NAME',
                # optional cache and secret overrides
                'REDIS_URL','OPENAI_API_KEY',
            ]
        ),
        "RANKALPHA_ENV": ENV_PROFILE,
    })(load_env_vars(INGESTION_ENV_PATH)),
    mounts=[
        Mount(source=PRICES_DATA_HOST, target="/data/prices", type="volume")
    ],
    mount_tmp_dir=False,
    working_dir='/app',
    dag=dag,
)

scorer = DockerOperator(
    task_id='run_scorer',
    image='rankalpha_scorer',
    api_version='auto',
    auto_remove='success',
    command='python apps/scorer/main.py',
    docker_url='unix://var/run/docker.sock',
    network_mode='rankalpha_net',
    do_xcom_push=False,
    cpus=float(Variable.get('SCORER_CPUS', default_var='1.0')),
    mem_limit=Variable.get('SCORER_MEM', default_var='1g'),
    environment=(lambda base: {
        **merge_env(
            base,
            [
                'DB_USERNAME','PASSWORD','HOST','PORT','DATABASE_NAME',
                'REDIS_URL'
            ]
        ),
        "RANKALPHA_ENV": ENV_PROFILE,
    })(load_env_vars(INGESTION_ENV_PATH)),
    mounts=[
        Mount(source=PRICES_DATA_HOST, target="/data/prices", type="volume")
    ],
    mount_tmp_dir=False,
    working_dir='/app',
    dag=dag,
)

# AI Analysis task - runs the sentiment/AI analysis for scheduled stocks
# AI Analysis task (consensus batch mode) – runs a one-off consensus batch and exits
ai_analysis = DockerOperator(
    task_id='run_ai_analysis',
    image='rankalpha_sentiment',
    api_version='auto',
    auto_remove='success',
    command='uv run main.py',
    docker_url='unix://var/run/docker.sock',
    network_mode='rankalpha_net',
    do_xcom_push=False,
    cpus=float(Variable.get('SENTIMENT_CPUS', default_var='1.0')),
    mem_limit=Variable.get('SENTIMENT_MEM', default_var='2g'),
    environment=(lambda base: {
        **merge_env(
            base,
            [
                'DB_USERNAME','PASSWORD','HOST','PORT','DATABASE_NAME',
                'REDIS_URL','OPENAI_API_KEY',
            ]
        ),
        # Profile into container
        'RANKALPHA_ENV': ENV_PROFILE,
        # Secrets/flags from Airflow Variables with sane defaults
        'OPENAI_API_KEY': Variable.get('OPENAI_API_KEY', default_var=base.get('OPENAI_API_KEY', '')),
        'SENTIMENT_USE_CONSENSUS': Variable.get('SENTIMENT_USE_CONSENSUS', default_var='true'),
        'SENTIMENT_CONSENSUS_MIN_APPEARANCES': Variable.get('SENTIMENT_CONSENSUS_MIN_APPEARANCES', default_var='2'),
        'SENTIMENT_CONSENSUS_MIN_STYLES': Variable.get('SENTIMENT_CONSENSUS_MIN_STYLES', default_var='1'),
        'SENTIMENT_CONSENSUS_LIMIT': Variable.get('SENTIMENT_CONSENSUS_LIMIT', default_var='10'),
        'SENTIMENT_CONSENSUS_BATCH_ONLY': Variable.get('SENTIMENT_CONSENSUS_BATCH_ONLY', default_var='true'),
        'SENTIMENT_SKIP_IF_WITHIN_DAYS': Variable.get('SENTIMENT_SKIP_IF_WITHIN_DAYS', default_var=base.get('SENTIMENT_SKIP_IF_WITHIN_DAYS', '1')),
        # Ensure logs path is writable volume
        'SENTIMENT_DATA_DIR': base.get('SENTIMENT_DATA_DIR', '/data'),
    })(load_env_vars(SENTIMENT_ENV_PATH)),
    mounts=[
        Mount(source="company_reports", target="/data/company_reports", type="volume"),
        Mount(source="analysis_schedule", target="/data/analysis_schedule", type="volume")
    ],
    mount_tmp_dir=False,
    working_dir='/app/apps/sentiment',
    dag=dag,
)

# Update grading after scoring and AI analysis complete
update_grading = BashOperator(
    task_id='update_grading',
    bash_command="curl -sf -X GET $API_URL/api/v1/grading/refresh || exit 1",
    env={
        **load_env_vars(f"/opt/rankalpha/env/{ENV_PROFILE}/api.env"),
        "RANKALPHA_ENV": ENV_PROFILE,
        "API_URL": Variable.get("API_URL", default_var="http://api:6080"),
    },
    dag=dag,
)

# Fallback: refresh MV directly via psql if API is down
refresh_mv_direct = DockerOperator(
    task_id='refresh_mv_direct',
    image='postgres:16',
    api_version='auto',
    auto_remove='success',
    command='bash -lc "psql -h ${HOST} -p ${PORT:-5432} -U ${DB_USERNAME} -d ${DATABASE_NAME} -c \"REFRESH MATERIALIZED VIEW CONCURRENTLY rankalpha.mv_latest_grades\" || psql -h ${HOST} -p ${PORT:-5432} -U ${DB_USERNAME} -d ${DATABASE_NAME} -c \"REFRESH MATERIALIZED VIEW rankalpha.mv_latest_grades\""',
    docker_url='unix://var/run/docker.sock',
    network_mode='rankalpha_net',
    do_xcom_push=False,
    cpus=float(Variable.get('PSQL_CPUS', default_var='0.5')),
    mem_limit=Variable.get('PSQL_MEM', default_var='256m'),
    environment=(lambda base: {
        **merge_env(
            base,
            ['DB_USERNAME','PASSWORD','HOST','PORT','DATABASE_NAME']
        ),
        'PGPASSWORD': base.get('PASSWORD', ''),
    })(load_env_vars(INGESTION_ENV_PATH)),
    mount_tmp_dir=False,
    working_dir='/',
    dag=dag,
    trigger_rule='one_failed',  # run only if update_grading fails
)

# Notify frontend to refresh data via API call
notify_frontend = BashOperator(
    task_id='notify_frontend',
    bash_command="""
    # Send a signal to the frontend that new data is available
    # The frontend should have a polling mechanism or websocket to detect this
    curl -X POST http://frontend:3000/api/refresh-data || true
    echo "Frontend notification sent"
    """,
    dag=dag,
    trigger_rule='one_success',  # proceed if either API refresh or fallback succeeded
)

# Define task dependencies
# 1. Run ingestion first
# 2. Then run scorer
# 3. Run AI analysis in parallel with scorer (they can run simultaneously)
# 4. After both scorer and AI analysis complete, update grading
# 5. Finally notify frontend
ingestion >> [scorer, ai_analysis] >> update_grading
update_grading >> [notify_frontend, refresh_mv_direct]
refresh_mv_direct >> notify_frontend
