# RankAlpha API Service

## Purpose
The API service provides a RESTful interface for the RankAlpha platform, serving as the primary backend for the frontend application and external integrations. It exposes endpoints for stock grading, signal analysis, backtesting, pipeline monitoring, and data refresh operations.

## Technologies & Tools

### Core Framework
- **FastAPI**: Modern, high-performance Python web framework with automatic OpenAPI documentation
- **Pydantic**: Data validation and settings management using Python type annotations
- **Uvicorn**: Lightning-fast ASGI server for production deployment

### Database & ORM
- **SQLAlchemy 2.0**: SQL toolkit and ORM for database operations
- **PostgreSQL**: Primary database (via psycopg2-binary)
- **Database Partitioning**: Leverages PostgreSQL table partitions for performance

### Additional Libraries
- **NumPy**: Numerical computing for financial calculations
- **Python-multipart**: Form data parsing support

## Design Principles

### 1. **RESTful Architecture**
- Resource-based URLs following REST conventions
- Standard HTTP methods (GET, POST, PUT, DELETE)
- JSON request/response format
- Consistent error handling and status codes

### 2. **Modular Router Design**
- Domain-specific routers for logical separation
- Each router handles a specific business domain
- Shared database session management via dependency injection

### 3. **Auto-Generated CRUD Operations**
- `router_factory.py` automatically generates CRUD endpoints from SQLAlchemy models
- Reduces boilerplate code and ensures consistency
- Supports pagination, filtering, and sorting out of the box

### 4. **Type Safety & Validation**
- Pydantic models for request/response schemas
- Automatic request validation and serialization
- Type hints throughout for better IDE support and runtime validation

### 5. **Database Connection Pooling**
- Efficient connection management via SQLAlchemy
- Session-per-request pattern with automatic cleanup
- Transaction support with proper rollback handling

## Project Structure

### Core Files

#### `main.py`
- FastAPI application initialization
- CORS configuration for frontend integration
- Router registration and mounting
- Automatic OpenAPI documentation setup
- Health check endpoints

#### `database.py`
- SQLAlchemy engine and session configuration
- Database connection management
- Session factory with dependency injection support

#### `schemas.py`
- Pydantic models for API request/response validation
- Data transfer objects (DTOs) for API contracts
- Complex type definitions for financial data structures

#### `router_factory.py`
- Generic CRUD endpoint generator
- Automatic pagination, filtering, and sorting
- Model-to-schema mapping
- Error handling and validation

### Routers Directory (`routers/`)

#### `grading.py`
- **Purpose**: Stock grading and ranking endpoints
- **Key Endpoints**:
  - `GET /grades`: Retrieve stock leaderboard with A-F grades
  - `GET /grades/{symbol}`: Individual stock grade details
  - `GET /asset/{symbol}`: Comprehensive asset analysis
- **Features**: Grade calculation, percentile rankings, sector comparisons

#### `signals.py`
- **Purpose**: Trading signal analysis and comparison
- **Key Endpoints**:
  - `GET /leaderboard`: Signal strength rankings
  - `GET /compare`: Multi-signal comparison
  - `GET /historical/{symbol}`: Historical signal data
- **Features**: Signal aggregation, trend analysis, performance metrics

#### `backtest.py`
- **Purpose**: Strategy backtesting and performance analysis
- **Key Endpoints**:
  - `POST /quick`: Fast strategy testing with basic metrics
  - `POST /full`: Comprehensive backtesting with detailed analytics
  - `GET /strategies`: Available strategy configurations
- **Features**: Risk metrics, Sharpe ratio, maximum drawdown calculations

#### `pipeline.py`
- **Purpose**: Data pipeline monitoring and management
- **Key Endpoints**:
  - `GET /health`: Overall system health status
  - `GET /status/{component}`: Component-specific health checks
  - `GET /data-quality`: Data completeness and quality metrics
- **Features**: Real-time monitoring, error tracking, performance metrics

## API Patterns & Best Practices

### Error Handling
```python
- HTTPException for client errors (4xx)
- Detailed error messages with proper status codes
- Structured error responses with error codes and descriptions
```

### Pagination
```python
- Limit/offset based pagination
- Default limits to prevent overwhelming responses
- Total count included in paginated responses
```

### Database Sessions
```python
- Session per request pattern
- Automatic session cleanup on request completion
- Transaction rollback on errors
```

### Response Models
```python
- Consistent response structure across endpoints
- Nested models for complex data relationships
- Optional fields with sensible defaults
```

## Running the Service

### Local Development
```bash
cd apps/api
uv venv
uv sync --locked

# Set Python path for imports
export PYTHONPATH=../..  # Linux/macOS
$env:PYTHONPATH = '../..'  # PowerShell

# Run with auto-reload
uv run uvicorn src.main:app --reload --port 6080
```

### Docker Deployment
```bash
# From project root
docker compose -f compose/docker-compose.yml up api
```

### Environment Configuration
- Configuration loaded from `/env/{RANKALPHA_ENV}/api.env`
- Supports multiple environments (local, localws, production)
- Environment variables for database connection, CORS origins, etc.

## API Documentation

### Interactive Documentation
- Swagger UI: http://localhost:6080/ (root)
- OpenAPI Schema: http://localhost:6080/openapi.json

### Notes on Views
- The API exposes read‑only models for:
  - `vw_ai_analysis_full` – denormalized AI output for easy consumption.
  - `v_latest_screener_consensus` – consensus aggregation across screener styles/sources.

### Authentication
- JWT tokens with Google OAuth integration (planned)
- API key authentication for service-to-service communication
- Rate limiting and request throttling

## Testing

### Unit Tests
```bash
pytest tests/api/
```

### Integration Tests
- Test database connections
- Verify endpoint responses
- Validate data transformations

## Performance Considerations

### Optimizations
- Database query optimization with proper indexing
- Lazy loading for related objects
- Response caching for frequently accessed data
- Connection pooling for database efficiency

### Monitoring
- Request/response logging
- Performance metrics tracking
- Error rate monitoring
- Database query performance analysis

## Future Enhancements

### Planned Features
- WebSocket support for real-time updates
- GraphQL endpoint for flexible queries
- Enhanced caching with Redis integration
- API versioning strategy
- Rate limiting per user/API key
- Webhook support for event notifications

## Dependencies

### Internal
- `common`: Shared models, CRUD operations, and utilities

### External
See `pyproject.toml` for complete dependency list with versions.

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify PostgreSQL is running
   - Check connection string in environment variables
   - Ensure database migrations have run

2. **Import Errors**
   - Set PYTHONPATH correctly
   - Ensure common package is installed in editable mode

3. **CORS Issues**
   - Verify frontend URL in CORS configuration
   - Check allowed origins in environment variables

## Contributing

- Follow existing code patterns and style
#### `ai_analysis.py`
- Purpose: Serve consolidated AI analysis snapshots from the denormalized view
- Key Endpoints:
  - `GET /api/v1/ai-analysis` – list with filters (symbol, date range, pagination)
  - `GET /api/v1/ai-analysis/{symbol}` – latest for a symbol
  - `GET /api/v1/ai-analysis/id/{analysis_id}` – specific record by UUID

#### `screener.py`
- Purpose: Latest‑day screener consensus (per‑symbol) across styles/sources
- Key Endpoints:
  - `GET /api/v1/screener/consensus` – one row per symbol with appearances, styles, and `consensus_score`

#### `technicals.py`
- Purpose: Serve technical indicators computed from ingested OHLCV
- Key Endpoints:
  - `GET /api/v1/technicals/latest?symbol=SYM` – latest snapshot (SMA/EMA/RSI/ATR/MACD/Bollinger/returns, etc.) from `vw_latest_technicals`
  - `GET /api/v1/technicals/series?symbol=SYM&indicators=SMA20,RSI14&days=120` – timeseries of selected indicators from `fact_technical_indicator`
- Add type hints to all functions
- Update OpenAPI schemas when adding endpoints
- Write tests for new functionality
- Document complex business logic
