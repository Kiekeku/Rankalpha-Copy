from models import DimSource, DimStyle, FactScreenerRank


def test_models_available():
    assert DimSource.__tablename__ == "dim_source"
    assert DimStyle.__tablename__ == "dim_style"
    assert FactScreenerRank.__tablename__ == "fact_screener_rank"
