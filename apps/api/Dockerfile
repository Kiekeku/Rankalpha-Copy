FROM ghcr.io/astral-sh/uv:python3.12-alpine AS builder

WORKDIR /app

# Copy the entire apps directory structure to maintain relative paths
COPY apps/api ./apps/api
COPY apps/common ./apps/common

# Create venv and install dependencies from api directory
ENV UV_PROJECT_ENVIRONMENT=/opt/venv
RUN uv venv --python 3.12 /opt/venv

# Change to api directory and sync dependencies
WORKDIR /app/apps/api
RUN uv sync --locked

# Runtime stage
FROM python:3.12-alpine

RUN addgroup -S app && adduser -S -G app -D app

# Copy virtual environment and source
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/uv /usr/local/bin/uv

# Install curl for health checks
RUN apk add --no-cache curl

# Set environment variables
ENV VENV_PATH=/opt/venv
ENV UV_PROJECT_ENVIRONMENT=${VENV_PATH}
ENV PATH="/opt/venv/bin:/usr/local/bin:$PATH"
ENV PYTHONPATH="/app/apps"

WORKDIR /app/apps/api

RUN chown -R app:app /opt/venv /app

USER app

EXPOSE 6080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:6080/ || exit 1

# Start the FastAPI app
CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "6080"]
