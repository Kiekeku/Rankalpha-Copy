# RankAlpha Score Engine

## Purpose
The Scorer service calculates financial metrics and generates investment scores for stocks based on momentum, value, and other quantitative factors. It transforms raw market data into actionable investment signals, providing the core ranking logic for the RankAlpha platform.

## Technologies & Tools

### Core Technologies
- **Python 3.12**: High-performance computation runtime
- **NumPy**: Vectorized numerical operations
- **Pandas**: Time-series analysis and data manipulation
- **SQLAlchemy**: Database operations and queries

### Calculation Libraries
- **SciPy**: Statistical functions and optimizations
- **TA-Lib**: Technical analysis indicators (optional)
- **Scikit-learn**: Machine learning models for scoring

## Design Principles

### 1. **Reproducibility**
- Deterministic calculations
- Version-controlled scoring algorithms
- Audit trail for score changes
- Point-in-time accuracy

### 2. **Performance**
- Vectorized computations
- Efficient database queries
- Batch processing capabilities
- Caching of intermediate results

### 3. **Flexibility**
- Configurable scoring parameters
- Pluggable metric modules
- Custom weighting schemes
- A/B testing support

### 4. **Transparency**
- Explainable score components
- Calculation breakdowns
- Historical score tracking
- Debug mode for validation

## Project Structure

### Core Files

#### `main.py`
- **Purpose**: Main orchestration for score calculation pipeline
- **Key Functions**:
  - `calculate_all_scores()`: Run complete scoring pipeline
  - `calculate_momentum_scores()`: Price and volume momentum metrics
  - `calculate_value_scores()`: Fundamental value metrics
  - `calculate_quality_scores()`: Company quality indicators
  - `calculate_composite_scores()`: Weighted combination scores
  - `rank_and_percentile()`: Convert scores to rankings
  - `store_results()`: Persist scores to database

## Scoring Methodology

### Momentum Scores
```python
# Price Momentum Components
- 1-month return
- 3-month return  
- 6-month return
- 12-month return
- Risk-adjusted returns (Sharpe ratio)
- Relative strength vs market
- Volume momentum
- Price acceleration
```

### Value Scores
```python
# Fundamental Value Components
- P/E ratio (inverse scoring)
- P/B ratio (inverse scoring)
- P/S ratio (inverse scoring)
- EV/EBITDA (inverse scoring)
- Free cash flow yield
- Dividend yield
- PEG ratio
- Graham number comparison
```

### Quality Scores
```python
# Company Quality Components
- Return on equity (ROE)
- Return on assets (ROA)
- Gross margin trends
- Debt/equity ratio (inverse)
- Current ratio
- Revenue growth stability
- Earnings consistency
- Cash flow quality
```

### Sentiment Integration
```python
# Sentiment Components (from sentiment service)
- News sentiment score
- Analyst recommendations
- Social media sentiment
- Insider trading signals
- Options flow indicators
```

## Calculation Pipeline

### Daily Processing Flow
1. **Data Retrieval**: Load latest prices and fundamentals
2. **Preprocessing**: Clean and normalize data
3. **Feature Engineering**: Technical indicators are computed centrally during ingestion from canonical Parquet OHLCV and stored in Postgres (`fact_technical_indicator`). The scorer reuses these values (via DB/API) rather than recalculating them.
4. **Score Calculation**: Apply scoring algorithms
5. **Normalization**: Z-score or percentile normalization
6. **Ranking**: Generate relative rankings
7. **Composite Scoring**: Weight and combine sub-scores
8. **Validation**: Quality checks and anomaly detection
9. **Storage**: Save to `fact_score_history` (scores). Technical indicators are saved by ingestion in `fact_technical_indicator` and exposed via `vw_latest_technicals`.
10. **Notification**: Alert downstream services

### Score Normalization
```python
def normalize_scores(scores: pd.Series) -> pd.Series:
    """Normalize scores to 0-100 scale"""
    # Z-score normalization
    z_scores = (scores - scores.mean()) / scores.std()
    
    # Convert to percentiles
    percentiles = stats.norm.cdf(z_scores) * 100
    
    return percentiles
```

### Weighting Schemes
```python
# Default weight configuration
SCORE_WEIGHTS = {
    'momentum': 0.30,
    'value': 0.25,
    'quality': 0.25,
    'sentiment': 0.20
}

# Sector-specific adjustments
SECTOR_ADJUSTMENTS = {
    'Technology': {'momentum': 1.2, 'value': 0.8},
    'Utilities': {'momentum': 0.8, 'value': 1.2}
}
```

## Performance Optimization

### Vectorized Operations
```python
# Efficient calculation using NumPy
def calculate_returns(prices: np.array, periods: list) -> dict:
    returns = {}
    for period in periods:
        returns[f'{period}d'] = (prices[-1] / prices[-period] - 1) * 100
    return returns
```

### Database Query Optimization
```python
# Efficient bulk fetch with joins
def fetch_scoring_data(symbols: list):
    return session.query(
        FactPriceHistory,
        FactFundamentals
    ).join(
        FactFundamentals,
        FactPriceHistory.symbol == FactFundamentals.symbol
    ).filter(
        FactPriceHistory.symbol.in_(symbols)
    ).all()
```

### Caching Strategy
- **Redis Cache**: Store intermediate calculations
- **Memory Cache**: Keep frequently used data in RAM
- **Result Cache**: Cache final scores for quick retrieval

## Configuration Management

### Scoring Parameters
```yaml
# config/scoring.yaml
momentum:
  lookback_periods: [20, 60, 120, 252]
  volume_weight: 0.2
  volatility_adjustment: true

value:
  metrics:
    - pe_ratio
    - pb_ratio
    - ps_ratio
  outlier_cap: 3  # Cap at 3 standard deviations

quality:
  min_history_days: 252
  growth_smoothing: 0.8
```

### Environment Variables
```env
# Scoring configuration
SCORING_MODE=production
PARALLEL_WORKERS=4
BATCH_SIZE=100

# Feature flags
ENABLE_ML_SCORING=false
ENABLE_SECTOR_ADJUST=true
```

## Quality Assurance

### Validation Checks
```python
def validate_scores(scores: pd.DataFrame) -> bool:
    """Validate score integrity"""
    checks = [
        scores['total_score'].between(0, 100).all(),
        scores['rank'].is_unique,
        scores.isnull().sum().sum() == 0,
        (scores['percentile'] >= 0).all()
    ]
    return all(checks)
```

### Backtesting Integration
- Historical score calculation
- Performance attribution
- Factor analysis
- Regime testing

## Monitoring & Alerts

### Key Metrics
- **Score Distribution**: Mean, std dev, skewness
- **Coverage**: Percentage of stocks scored
- **Calculation Time**: Pipeline performance
- **Score Stability**: Day-over-day changes
- **Anomalies**: Outlier detection

### Health Checks
```python
def health_check():
    return {
        "status": "healthy",
        "last_calculation": last_run_time,
        "stocks_scored": total_scored,
        "average_score": avg_score,
        "calculation_time_ms": calc_time
    }
```

## Running the Service

### Local Development
```bash
cd apps/scorer
uv venv
uv sync --locked
uv run python src/main.py
```

### Docker Deployment
```bash
# Part of docker-compose stack
docker compose -f compose/docker-compose.yml up scorer
```

### Manual Scoring
```python
# Score specific symbols
python src/main.py --symbols AAPL,MSFT,GOOGL

# Recalculate all scores
python src/main.py --full-refresh

# Debug mode with detailed output
python src/main.py --debug --symbol AAPL
```

## Testing Strategy

### Unit Tests
```bash
pytest tests/scorer/
```

### Test Coverage
- Score calculation accuracy
- Ranking algorithm correctness
- Edge case handling
- Performance benchmarks

## Advanced Features

### Machine Learning Integration
```python
# Optional ML-based scoring
class MLScorer:
    def __init__(self):
        self.model = load_model('models/score_predictor.pkl')
    
    def predict_score(self, features):
        return self.model.predict(features)
```

### Factor Analysis
```python
# Analyze factor contributions
def factor_attribution(symbol: str):
    scores = get_component_scores(symbol)
    return {
        'momentum_contribution': scores['momentum'] * WEIGHTS['momentum'],
        'value_contribution': scores['value'] * WEIGHTS['value'],
        # ... other factors
    }
```

## Future Enhancements

### Planned Features
- Machine learning score predictions
- Real-time scoring updates
- Custom scoring models per user
- Alternative data integration
- Factor timing models
- Risk-adjusted scoring
- Peer group comparisons
- ESG score integration

## Dependencies

### Internal
- `common`: Database models and CRUD operations

### External
- numpy>=1.24.0
- pandas>=2.0.0
- scipy>=1.10.0
- scikit-learn>=1.3.0 (optional)

## Troubleshooting

### Common Issues

1. **Missing Data**
   - Check data ingestion completeness
   - Verify symbol coverage
   - Review data quality filters

2. **Score Anomalies**
   - Validate input data ranges
   - Check for calculation overflows
   - Review normalization parameters

3. **Performance Issues**
   - Increase batch size
   - Enable parallel processing
   - Optimize database queries

4. **Inconsistent Rankings**
   - Verify sort stability
   - Check tie-breaking rules
   - Review score precision

## Contributing

### Adding New Metrics
1. Define metric in `metrics/` module
2. Add calculation function
3. Update scoring weights
4. Create unit tests
5. Document methodology
6. Validate with backtesting
