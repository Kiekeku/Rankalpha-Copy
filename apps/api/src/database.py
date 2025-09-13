from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from apps.common.src.logging import get_logger
from .settings import Settings 
from apps.common.src.models import Base               

settings = Settings()
engine = create_engine(
    f"postgresql+psycopg2://{settings.db_username}:{settings.password}"
    f"@{settings.host}:{settings.port}/{settings.database_name}",
    pool_pre_ping=True,
    future=True,
)

# Classic scoped session factory
SessionLocal: sessionmaker[Session] = sessionmaker(
    autocommit=False, autoflush=False, bind=engine, future=True
)

def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency – yield a session per‑request and commit/rollback safely."""
    db: Session = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
