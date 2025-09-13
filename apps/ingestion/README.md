# RankAlpha Data Ingestion Service

## Purpose
The Ingestion service is responsible for collecting, validating, and loading financial data from various external sources into the RankAlpha platform. It acts as the entry point for all market data, ensuring data quality and consistency before storage in the PostgreSQL database.

## Technologies & Tools

### Core Technologies
- **Python 3.12**: Async-capable runtime for concurrent data fetching
- **SQLAlchemy**: Database ORM for data persistence
- **Pydantic**: Data validation and settings management

### Data Sources
- **NorgateData**: End-of-day price feeds and corporate actions
- **yfinance**: Yahoo Finance for fundamentals and historical prices
- **Finviz**: Market screener for stock discovery
- **OpenAI**: News search and content aggregation
- **Custom APIs**: Additional data provider integrations

### Data Processing
- **Pandas**: Data manipulation and transformation
- **NumPy**: Numerical computations
- **AsyncIO**: Concurrent data fetching

## Design Principles

### 1. **Reliability First**
- Robust error handling with retries
- Data validation at ingestion point
- Transactional consistency
- Audit trail for all operations

### 2. **Scalability**
- Asynchronous data fetching
- Batch processing capabilities
- Parallel source processing
- Rate limiting and throttling

### 3. **Data Quality**
- Schema validation on input
- Duplicate detection and handling
- Data completeness checks
- Anomaly detection

### 4. **Modularity**
- Separate modules per data source
- Pluggable architecture for new sources
- Common interface for all ingestors
- Configurable transformation pipelines

## Project Structure

### Core Files

#### `main.py`
- Purpose: Orchestrate downloads of historical prices to Parquet under `/data/prices`.
- Current universe source: the latest‑day screener consensus view
  (`v_latest_screener_consensus`), ordered by `consensus_score` desc.
  This yields one row per symbol and implicitly prioritizes high‑consensus names.

#### `ingest_fundamentals_yfin.py`
- **Purpose**: Yahoo Finance fundamentals ingestion
- **Key Features**:
  - Company financials (income statement, balance sheet, cash flow)
  - Key ratios and metrics
  - Analyst recommendations
  - Earnings data
  - Historical price adjustments

### Data Source Modules

#### NorgateData Integration (`norgate/`)
- **End-of-Day Prices**: Daily OHLCV data
- **Corporate Actions**: Splits, dividends, mergers
- **Index Constituents**: S&P 500, NASDAQ membership
- **Delisted Securities**: Historical survivorship bias handling
- **Data Quality**: Professional-grade cleaned data

#### Yahoo Finance Integration
```python
# Key data points ingested:
- Market capitalization
- P/E, P/B, P/S ratios
- Revenue and earnings growth
- Debt metrics
- Dividend information
- Historical prices
```

> Note: universe selection is now centralized via the database views
> `v_latest_screener_consensus` (preferred) and/or `v_latest_screener_values` (joined snapshot).

### Technical Indicators (new)
After parquet prices are present, the scorer computes daily technical indicators and stores them in Postgres:

- Table: `fact_technical_indicator (date_key, stock_key, indicator_code, value)` with upsert semantics
- View: `vw_latest_technicals` – pivoted snapshot for easy consumption by API/clients
- Indicators included:
  - SMA20/50/200, EMA12/26, RSI14 (Wilder), ATR14
  - Bollinger Bands (20, 2σ): BB_UPPER, BB_MIDDLE, BB_LOWER
  - MACD (12,26,9): MACD, MACD_SIGNAL, MACD_HIST
  - Rolling returns: RET_5D, 20D, 60D, 120D
  - VOL_Z20 (z-score), DIST_52W_HIGH (%)

These are available via the API:
  - `GET /api/v1/technicals/latest?symbol=SYM`
  - `GET /api/v1/technicals/series?symbol=SYM&indicators=SMA20,RSI14&days=120`

## Data Flow Pipeline

### Ingestion Process
1. **Source Connection**: Establish API/database connections
2. **Data Retrieval**: Fetch raw data with pagination
3. **Validation**: Schema and quality checks
4. **Transformation**: Normalize to internal format
5. **Deduplication**: Remove duplicate records
6. **Storage**: Bulk insert to staging tables
7. **Processing**: Move to production tables
8. **Notification**: Alert downstream services

### Error Handling
```python
# Retry strategy with exponential backoff
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
def fetch_data(source):
    # Fetch with automatic retry
    pass
```

## Configuration Management

### Environment Variables
```env
# Data source credentials
NORGATE_API_KEY=xxx
FINVIZ_API_KEY=xxx
OPENAI_API_KEY=xxx

# Database configuration
DATABASE_URL=postgresql://...

# Ingestion settings
BATCH_SIZE=1000
CONCURRENT_SOURCES=4
RETRY_ATTEMPTS=3
```

### Source-Specific Configuration
```yaml
# config/sources.yaml
norgate:
  enabled: true
  schedule: "0 6 * * *"  # Daily at 6 AM
  symbols: ["SPX", "NDX"]
  
yfinance:
  enabled: true
  batch_size: 50
  rate_limit: 2000  # requests per hour
```

## Data Validation

### Schema Validation
```python
class PriceData(BaseModel):
    symbol: str
    date: datetime
    open: float = Field(gt=0)
    high: float = Field(gt=0)
    low: float = Field(gt=0)
    close: float = Field(gt=0)
    volume: int = Field(ge=0)
    
    @validator('high')
    def high_gte_low(cls, v, values):
        if 'low' in values and v < values['low']:
            raise ValueError('High must be >= Low')
        return v
```

### Quality Checks
- **Completeness**: Required fields present
- **Range Validation**: Values within expected bounds
- **Consistency**: Cross-field validation
- **Timeliness**: Data freshness checks

## Performance Optimization

### Batch Processing
```python
# Efficient bulk inserts
def bulk_insert(records):
    with db.begin() as conn:
        conn.execute(
            insert(Table).values(records)
            .on_conflict_do_update(...)
        )
```

### Concurrent Fetching
```python
# Parallel source processing
async def fetch_all_sources():
    tasks = [
        fetch_norgate(),
        fetch_yfinance(),
        fetch_finviz()
    ]
    results = await asyncio.gather(*tasks)
    return results
```

### Caching Strategy
- **Local Cache**: Recently fetched symbols
- **Redis Cache**: Shared across instances
- **TTL Management**: Automatic cache expiry

## Monitoring & Alerting

### Metrics Tracked
- **Data Freshness**: Last successful ingestion time
- **Error Rates**: Failed fetches per source
- **Data Quality**: Validation failure rates
- **Performance**: Ingestion throughput
- **Completeness**: Missing data detection

### Health Checks
```python
def health_check():
    return {
        "status": "healthy",
        "last_run": last_ingestion_time,
        "sources": {
            "norgate": {"status": "up", "last_fetch": "..."},
            "yfinance": {"status": "up", "last_fetch": "..."}
        }
    }
```

## Running the Service

### Local Development
```bash
cd apps/ingestion
uv venv
uv sync --locked
uv run python src/main.py
```

### Docker Deployment
```bash
# Part of docker-compose stack
docker compose -f compose/docker-compose.yml up ingestion
```

### Manual Trigger
```python
# Run specific source
python src/main.py --source yfinance --symbols AAPL,MSFT

# Full ingestion
python src/main.py --full-refresh
```

## Testing Strategy

### Unit Tests
```bash
pytest tests/ingestion/
```

### Integration Tests
- Mock external API responses
- Test data validation logic
- Verify database transactions
- Check error handling

## Error Recovery

### Failure Scenarios
1. **API Rate Limiting**: Exponential backoff
2. **Network Failures**: Automatic retry
3. **Data Corruption**: Validation and rejection
4. **Database Errors**: Transaction rollback
5. **Source Unavailable**: Skip and alert

### Recovery Strategies
- **Checkpoint System**: Resume from last successful point
- **Partial Commits**: Save successful batches
- **Dead Letter Queue**: Store failed records
- **Manual Intervention**: Admin tools for fixes

## Future Enhancements

### Planned Features
- Real-time streaming data ingestion
- WebSocket connections for live prices
- Alternative data sources (social media, satellite)
- Machine learning for anomaly detection
- Data lineage tracking
- Automated source discovery
- GraphQL API for flexible queries

## Dependencies

### Internal
- `common`: Shared models and database operations

### External
- norgatedata (if available)
- yfinance>=0.2.0
- pandas>=2.0.0
- numpy>=1.24.0

## Troubleshooting

### Common Issues

1. **API Authentication Failures**
   - Verify API keys in environment
   - Check credential expiration
   - Confirm IP whitelisting

2. **Rate Limiting**
   - Adjust RATE_LIMIT settings
   - Implement request queuing
   - Use multiple API keys

3. **Data Quality Issues**
   - Review validation rules
   - Check source data quality
   - Adjust tolerance thresholds

4. **Performance Problems**
   - Increase batch sizes
   - Add more workers
   - Optimize database indexes

## Contributing

### Adding New Data Sources
1. Create module in `src/sources/`
2. Implement common interface
3. Add configuration options
4. Write validation schemas
5. Create unit tests
6. Document API requirements
