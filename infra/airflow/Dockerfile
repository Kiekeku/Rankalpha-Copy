FROM apache/airflow:2.11.0-python3.12

USER root

RUN apt-get update \
 && apt-get install -y docker.io \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY infra/airflow/wait-for-it.sh /opt/wait-for-it.sh
RUN chmod +x /opt/wait-for-it.sh

USER airflow

COPY infra/airflow/pyproject.toml infra/airflow/uv.lock ./

ENV VENV_PATH="/app/.venv"
ENV PATH="$VENV_PATH/bin:$PATH"
ENV PYTHONPATH=/app

RUN pip install uv \
 && uv pip install --no-deps -r <(uv pip compile --output -)

WORKDIR /opt/airflow
COPY infra/airflow/dags/ ./dags