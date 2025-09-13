# RankAlpha Docker Deployment Guide

This guide explains how to deploy the complete RankAlpha stack using Docker Compose, including the new FastAPI backend and Next.js frontend.

## 🏗️ Architecture Overview

The deployment includes:

- **Frontend**: Next.js web application (port 3000)
- **API**: FastAPI backend with grading system (port 6080) 
- **Database**: PostgreSQL with migrations (port 6543)
- **Cache**: Redis for performance (port 6379)
- **Airflow**: Workflow orchestration (port 8080)
- **Supporting Services**: SFTP, Ingestion, Scorer, Sentiment

## 🚀 Quick Start

### Prerequisites

- Docker Desktop or Docker Engine
- Docker Compose v2+
- 8GB+ RAM recommended
- PowerShell or CMD (Windows) - **NOT Git Bash**

### Deploy the Stack

```bash
# Navigate to compose directory
cd compose

# Start all services
docker compose up --build

# Or run in background
docker compose up --build -d
```

### Verify Deployment

```bash
# Run the test script
../scripts/test-docker.sh

# Or manually check services
curl http://localhost:6080/          # API docs
curl http://localhost:3000/          # Frontend
curl http://localhost:6080/api/v1/grading/grades  # API endpoint
```

## 📱 Application URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Web application dashboard |
| API | http://localhost:6080 | FastAPI backend |
| API Docs | http://localhost:6080/ | Interactive API documentation |
| Database | localhost:6543 | PostgreSQL (use database tools) |
| Airflow | http://localhost:8080 | Pipeline orchestration |
| Redis | localhost:6379 | Cache (use Redis CLI) |

## 🔧 Configuration

### Environment Variables

Services are configured via environment files in `/env/local/`:

- `api.env` - API service settings
- `database.env` - PostgreSQL configuration  
- `airflow.env` - Airflow settings
- Other service-specific configs

### Key API Settings

```env
# API Port
API_PORT=6080

# Database Connection
DATABASE_NAME=rankalpha
DB_USERNAME=rankalpha
HOST=database
PORT=5432

# CORS for Frontend
CORS_ORIGINS=["http://localhost:3000", "http://frontend:3000"]
```

### Frontend Settings

```env
# API Connection
NEXT_PUBLIC_API_URL=http://api:6080  # Internal Docker network
```

## 🏃‍♂️ Development Workflow

### Starting Services

```bash
# Full stack
docker compose up --build

# Specific services
docker compose up database cache api frontend

# View logs
docker compose logs -f api
docker compose logs -f frontend
```

### Making Changes

```bash
# Rebuild after code changes
docker compose up --build api frontend

# Restart single service
docker compose restart api
```

### Database Operations

```bash
# Run migrations
docker compose up flyway

# Connect to database
docker compose exec database psql -U rankalpha -d rankalpha

# View database logs
docker compose logs database
```

## 🔍 Troubleshooting

### Common Issues

**"Apps not found" errors on Windows:**
- Use PowerShell or CMD, NOT Git Bash
- Ensure paths use backslashes: `compose\docker-compose.yml`

**API not starting:**
```bash
# Check API logs
docker compose logs api

# Common issues:
# - Database not ready (wait 30-60 seconds)
# - Environment file missing
# - Python dependencies not installed
```

**Frontend not connecting to API:**
```bash
# Check network connectivity
docker compose exec frontend curl http://api:6080/

# Verify CORS settings in api.env
# Check frontend environment variables
```

**Database connection failed:**
```bash
# Verify database is running
docker compose ps database

# Check database logs
docker compose logs database

# Test connection
docker compose exec database pg_isready -U rankalpha
```

### Service Health Checks

All services include health checks:

```bash
# View service status
docker compose ps

# Services should show "healthy" status
# If "unhealthy", check logs for that service
```

### Reset Everything

```bash
# Stop and remove all containers, networks, volumes
docker compose down -v

# Rebuild from scratch
docker compose up --build
```

## 📊 Monitoring

### Viewing Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs api
docker compose logs frontend

# Follow logs in real-time
docker compose logs -f api
```

### Health Status

```bash
# Check service health
docker compose ps

# API health endpoint
curl http://localhost:6080/api/v1/pipeline/health

# Frontend health
curl http://localhost:3000
```

## 🎯 API Endpoints

The FastAPI backend provides these key endpoints:

### Grading System
- `GET /api/v1/grading/grades` - Stock leaderboard with A-F grades
- `GET /api/v1/grading/grades/{symbol}` - Individual stock grade
- `GET /api/v1/grading/asset/{symbol}` - Detailed asset analysis

### Signals Analysis  
- `GET /api/v1/signals/leaderboard` - Signal rankings
- `GET /api/v1/signals/compare` - Compare multiple signals
- `GET /api/v1/signals/historical/{symbol}` - Historical signal data

### Backtesting
- `POST /api/v1/backtest/quick` - Fast strategy testing
- `POST /api/v1/backtest/full` - Comprehensive backtest
- `GET /api/v1/backtest/strategies` - Available strategies

### Pipeline Monitoring
- `GET /api/v1/pipeline/health` - System health status
- `GET /api/v1/pipeline/status/{component}` - Component details
- `GET /api/v1/pipeline/data-quality` - Data quality checks

## 🔒 Security Notes

- Default passwords are used for development
- Change credentials for production deployment
- API keys and secrets should be externalized
- Consider using Docker Secrets for production

## 📈 Performance Tuning

### Resource Allocation

```yaml
# In docker-compose.yml, add resource limits:
services:
  api:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: "1.0"
```

### Scaling Services

```bash
# Scale specific services
docker compose up --scale api=2 --scale frontend=2
```

## 🚢 Production Deployment

For production:

1. Use environment-specific configs (`env/prod/`)
2. Set up proper secrets management
3. Configure SSL/TLS termination
4. Set up monitoring and alerting
5. Use managed database services
6. Implement backup strategies

## 🆘 Getting Help

- Check service logs: `docker compose logs [service]`
- View container status: `docker compose ps`
- Run health checks: `../scripts/test-docker.sh`
- Restart services: `docker compose restart [service]`
- Reset everything: `docker compose down -v && docker compose up --build`