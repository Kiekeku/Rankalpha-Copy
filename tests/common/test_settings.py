import os

from  apps.common.src.settings import Settings


def test_settings_from_env(monkeypatch):
    monkeypatch.setenv("DATABASE_NAME", "db")
    monkeypatch.setenv("DB_USERNAME", "user")
    monkeypatch.setenv("PASSWORD", "pass")
    monkeypatch.setenv("HOST", "localhost")
    monkeypatch.setenv("PORT", "5432")
    

    settings = Settings()
    assert settings.database_name == "db"
    assert settings.db_username == "user"
    assert settings.password == "pass"
    assert settings.host == "localhost"
    assert settings.port == 5432
  
