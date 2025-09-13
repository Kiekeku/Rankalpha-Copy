FROM python:3.12-slim

RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && apt-get clean

RUN pip install uv

WORKDIR /app

COPY common ./apps/common

ENV VENV_PATH="/app/.venv"
ENV PATH="$VENV_PATH/bin:$PATH"
ENV PYTHONPATH="/app"

COPY scorer/pyproject.toml scorer/uv.lock ./

RUN uv sync --locked

COPY scorer/src/ ./apps/scorer