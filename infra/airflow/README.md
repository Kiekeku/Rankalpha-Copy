# RankAlpha Airflow Orchestration

## Purpose
The Airflow infrastructure provides workflow orchestration for the RankAlpha data pipeline, coordinating the execution of data ingestion, scoring, sentiment analysis, and system updates. It ensures reliable, scheduled execution of all data processing tasks with proper dependency management and error handling.

## Technologies & Tools

### Core Framework
- **Apache Airflow**: Workflow orchestration platform
- **Docker**: Containerized task execution
- **Python**: DAG definitions and operators
- **Celery**: Distributed task execution (optional)

### Airflow Components
- **Scheduler**: Task scheduling and dependency management
- **Web UI**: Pipeline monitoring and management interface
- **Worker**: Task execution engine
- **Metadata Database**: PostgreSQL for workflow state

### Integration Technologies
- **Docker Operators**: Container-based task execution
- **Python Operators**: Native Python task execution
- **Bash Operators**: Shell command execution
- **HTTP Operators**: API interaction and notifications

## Design Principles

### 1. **Reliability**
- Automatic retries with exponential backoff
- Task dependency management
- Failure notifications and alerts
- Recovery mechanisms

### 2. **Observability**
- Comprehensive logging for all tasks
- Performance monitoring
- Task execution history
- Visual pipeline representation

### 3. **Scalability**
- Distributed task execution
- Resource allocation control
- Concurrent pipeline support
- Load balancing capabilities

### 4. **Maintainability**
- Modular DAG structure
- Reusable task templates
- Environment-specific configuration
- Version-controlled workflows

## Project Structure

### Core Files

#### `dags/pipeline.py`
- **Purpose**: Main data processing pipeline DAG
- **Key Components**:
  - `rankalpha_pipeline`: Daily orchestration workflow
  - **Schedule**: Daily at 6 AM UTC with startup trigger
  - **Tasks**:
    - `run_ingestion`: Data collection from external sources
    - `run_scorer`: Calculate momentum, value, and quality scores
    - `run_ai_analysis`: One‑off consensus batch (top screener consensus names); container exits after batch
    - `update_grading`: Refresh A-F grading system
    - `notify_frontend`: Signal frontend to refresh data

#### `scripts/trigger_dag_on_startup.py`
- **Purpose**: Automatic DAG triggering when Airflow starts
- **Key Features**:
  - Detects Airflow startup
  - Triggers pipeline automatically
  - Handles initial data processing
  - Ensures system readiness

### Docker Configuration

#### `Dockerfile`
- **Purpose**: Airflow container image definition
- **Key Features**:
  - Apache Airflow installation
  - Custom dependency installation
  - Environment configuration
  - Volume mount setup

## Pipeline Architecture

### Daily Processing Workflow

#### 1. Data Ingestion Task
```python
ingestion = DockerOperator(
    task_id='run_ingestion',
    image='rankalpha_ingestion',
    command='python apps/ingestion/main.py',
    network_mode='rankalpha_net',
    environment=load_env_vars(ENV_PATH)
)
```

#### 2. Score Calculation Task
```python
scorer = DockerOperator(
    task_id='run_scorer',
    image='rankalpha_scorer',
    command='python apps/scorer/main.py',
    depends_on_past=False
)
```

#### 3. AI Sentiment Analysis Task (Consensus Batch)
Runs a short, deterministic batch of top consensus symbols, then exits.

```python
ai_analysis = DockerOperator(
    task_id='run_ai_analysis',
    image='rankalpha_sentiment',
    command='uv run main.py',
    environment={
        # enable consensus mode
        'SENTIMENT_USE_CONSENSUS': 'true',
        'SENTIMENT_CONSENSUS_MIN_APPEARANCES': '2',
        'SENTIMENT_CONSENSUS_MIN_STYLES': '1',
        'SENTIMENT_CONSENSUS_LIMIT': '10',
        'SENTIMENT_CONSENSUS_BATCH_ONLY': 'true',
        'SENTIMENT_DATA_DIR': '/data',
    },
    # in parallel with scorer
)
```

The long‑running service can still run in scheduled mode outside Airflow; the batch
task keeps DAG timing tight and predictable.

#### 4. Grade Update Task
```python
update_grading = BashOperator(
    task_id='update_grading',
    bash_command='curl -X POST http://api:6080/api/v1/grading/refresh'
)
```

### Task Dependencies
```python
# Sequential execution flow
ingestion >> [scorer, ai_analysis] >> update_grading >> notify_frontend

# Parallel execution where possible
# scorer and ai_analysis run simultaneously after ingestion
```

## Configuration Management

### Environment Variables & Airflow Variables
```env
# Airflow configuration
AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=false
AIRFLOW__CORE__LOAD_EXAMPLES=false
AIRFLOW__WEBSERVER__EXPOSE_CONFIG=true

# Database connection
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql://...

# Resource limits
AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG=1
AIRFLOW__CORE__PARALLELISM=4
```

Use Airflow Variables to parameterize environment profile and sentiment flags:

- ENV_PROFILE: selects which `/opt/rankalpha/env/{profile}` folder to read (defaults to `RANKALPHA_ENV` or `local`).
- OPENAI_API_KEY: API key injected into the sentiment container (overrides file value).
- SENTIMENT_USE_CONSENSUS: `true|false` (default true in DAG example).
- SENTIMENT_CONSENSUS_MIN_APPEARANCES: e.g., `2`.
- SENTIMENT_CONSENSUS_MIN_STYLES: e.g., `1`.
- SENTIMENT_CONSENSUS_LIMIT: e.g., `10`.
- SENTIMENT_CONSENSUS_BATCH_ONLY: `true|false` (true makes the task exit after batch).
- SENTIMENT_SKIP_IF_WITHIN_DAYS: e.g., `1` (skip if last run within N days).

Resource tuning (optional)
- INGESTION_CPUS: e.g., `1.0`
- INGESTION_MEM: e.g., `1g`
- SCORER_CPUS: e.g., `1.0`
- SCORER_MEM: e.g., `1g`
- SENTIMENT_CPUS: e.g., `1.0`
- SENTIMENT_MEM: e.g., `2g`

Notes
- If these aren’t set, the DAG uses conservative defaults suitable for local dev.
- All DockerOperator tasks have `do_xcom_push=False` to reduce metadata volume.

Best practice
- Keep non‑secret defaults in mounted env files under `/opt/rankalpha/env/{profile}/`.
- Store secrets (API keys, passwords) as Airflow Variables or a secrets backend; the DAG merges them into the container env.
- Set `RANKALPHA_ENV` (or ENV_PROFILE) so services read the correct env folder.

### DAG Configuration
```python
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'email_on_failure': True,
    'email_on_retry': False
}

dag = DAG(
    'rankalpha_pipeline',
    default_args=default_args,
    schedule='0 6 * * *',  # Daily at 6 AM UTC
    max_active_runs=1,     # Prevent overlapping runs
    catchup=False          # Don't run historical dates
)
```

## Scheduling Strategy

### Daily Schedule
- **Time**: 6:00 AM UTC daily
- **Rationale**: After market close, before market open
- **Duration**: Approximately 30-45 minutes for full pipeline
- **Overlap Prevention**: max_active_runs=1

### Startup Trigger
- **Automatic**: Pipeline runs when Docker Compose starts
- **Purpose**: Ensure fresh data availability immediately
- **Implementation**: startup script monitors Airflow health

### Manual Execution
- **Web UI**: Trigger runs via Airflow interface
- **CLI**: Command-line DAG triggering
- **API**: Programmatic execution via REST API

## Monitoring & Alerting

### Airflow Web UI
- **Access**: http://localhost:8080
- **Credentials**: username: rankalpha, password: rankalpha
- **Features**:
  - Pipeline visualization
  - Task execution logs
  - Performance metrics
  - Manual controls

### Task Monitoring
```python
def task_success_callback(context):
    """Callback for successful task completion"""
    task_id = context['task_instance'].task_id
    execution_date = context['execution_date']
    # Send success notification
    
def task_failure_callback(context):
    """Callback for task failures"""
    # Send alert to operations team
    # Log failure details
    # Trigger recovery procedures
```

### Health Checks
- **Pipeline Status**: Overall workflow health
- **Task Performance**: Execution time trends
- **Resource Usage**: CPU, memory, disk utilization
- **Data Quality**: Validation of pipeline outputs

## Error Handling

### Retry Strategy
```python
# Automatic retries with delays
default_args = {
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
    'max_retry_delay': timedelta(minutes=30)
}
```

### Failure Recovery
- **Task Isolation**: Failed tasks don't affect others
- **Dependency Management**: Downstream tasks wait for upstream
- **Manual Intervention**: Admin can fix and restart tasks
- **Data Consistency**: Transactional operations where possible

### Alert Mechanisms
- **Email Notifications**: Send alerts on failures
- **Slack Integration**: Team notifications (configurable)
- **Dashboard Alerts**: Visual indicators in UI
- **Log Aggregation**: Centralized error tracking

## Performance Optimization

### Resource Management
```python
# Task resource allocation
task = DockerOperator(
    task_id='resource_intensive_task',
    docker_url='unix://var/run/docker.sock',
    cpus=2.0,
    mem_limit='4g'
)
```

### Parallel Processing
- **Independent Tasks**: Run scorer and AI analysis simultaneously
- **Resource Pooling**: Manage concurrent task limits
- **Load Balancing**: Distribute work across workers

### Data Volume Management
- **Incremental Processing**: Process only new/changed data
- **Batch Size Optimization**: Tune for memory efficiency
- **Storage Cleanup**: Automatic cleanup of temporary files

## Scripts Directory

### `trigger_dag_on_startup.py`
- **Purpose**: Automatic pipeline triggering on system start
- **Key Functions**:
  - `wait_for_airflow()`: Wait for Airflow to be ready
  - `trigger_dag()`: Initiate pipeline execution
  - `monitor_execution()`: Track pipeline progress

### Authentication Management
- **airflow_pw.json**: Encrypted password storage
- **User Management**: Admin user creation and management
- **API Authentication**: Token-based access control

## Docker Integration

### Network Configuration
```yaml
# docker-compose.yml integration
networks:
  rankalpha_net:
    driver: bridge

services:
  airflow:
    networks:
      - rankalpha_net
    depends_on:
      - postgres
      - redis
```

### Volume Mounts
```python
# Data persistence
mounts=[
    Mount(
        source='/data',
        target='/data',
        type='bind'
    )
]
```

## Development & Testing

### Local Development
```bash
# Start Airflow services
docker compose -f compose/docker-compose.yml up airflow

# Access web UI
open http://localhost:8080

# View logs
docker logs airflow-scheduler
docker logs airflow-webserver
```

### Testing DAGs
```bash
# Test DAG syntax
python -m pytest tests/airflow/

# Dry run tasks
airflow tasks test rankalpha_pipeline run_ingestion 2025-01-01

# Validate DAG structure
airflow dags validate rankalpha_pipeline
```

## Future Enhancements

### Planned Features
- **Dynamic DAG Generation**: Create pipelines programmatically
- **Machine Learning Pipelines**: Orchestrate model training
- **Real-time Processing**: Stream processing workflows
- **Multi-Environment Support**: Dev/staging/prod pipelines
- **Advanced Monitoring**: Custom metrics and dashboards
- **Auto-scaling**: Dynamic resource allocation
- **Data Lineage**: Track data flow across systems
- **A/B Testing**: Parallel pipeline execution

## Troubleshooting

### Common Issues

1. **DAG Import Errors**
   - Check Python syntax in DAG files
   - Verify import paths and dependencies
   - Review Airflow logs for details

2. **Task Execution Failures**
   - Check Docker container logs
   - Verify network connectivity
   - Confirm resource availability

3. **Scheduling Issues**
   - Verify timezone configuration
   - Check DAG scheduling parameters
   - Review execution history

4. **Performance Problems**
   - Monitor resource usage
   - Adjust parallelism settings
   - Optimize task definitions

## Contributing

### Adding New Tasks
1. Define task in DAG file
2. Configure dependencies
3. Add error handling
4. Write tests
5. Document task purpose
6. Update monitoring dashboards
