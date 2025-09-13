"""Logging utilities.

Ensures both module-level and root loggers have handlers so that
third-party libraries (e.g., OpenAI SDK, httpx) actually emit logs
when their log level is raised. This avoids the common pitfall where
the root logger has no handlers and debug logs are silently dropped.
"""

import logging
from logging import Logger
from logging.handlers import RotatingFileHandler


def _ensure_root_handler() -> None:
    """Attach a basic StreamHandler to the root logger if missing.

    This is intentionally minimal and idempotent. It does not change
    the root level (callers can still adjust levels), it only ensures
    there is at least one handler so that logs from other libraries
    propagate and are visible.
    """
    root = logging.getLogger()
    if not root.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        handler.setFormatter(formatter)
        root.addHandler(handler)


def get_logger(name: str, level: int = logging.INFO) -> Logger:
    """Create or retrieve a configured logger.

    Also ensures the root logger has a handler so that other library
    loggers (like 'openai' or 'httpx') can propagate and be seen when
    debug mode is enabled by the application.
    """
    _ensure_root_handler()
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(level)
        # Prevent duplicate emission via root when root also has handlers
        logger.propagate = False
    return logger


def add_rotating_file_handler(
    *,
    path: str,
    level: int = logging.DEBUG,
    max_bytes: int = 10 * 1024 * 1024,
    backup_count: int = 5,
) -> None:
    """Attach a RotatingFileHandler to the root logger if not already attached.

    Safe to call multiple times; it will de-duplicate by filename.
    """
    _ensure_root_handler()
    root = logging.getLogger()
    # De-duplicate by absolute filename
    try:
        from os.path import abspath
        abs_target = abspath(path)
    except Exception:
        abs_target = path
    for h in root.handlers:
        try:
            if isinstance(h, RotatingFileHandler) and getattr(h, "baseFilename", None) == abs_target:
                # Already attached
                return
        except Exception:
            continue
    fh = RotatingFileHandler(path, maxBytes=max_bytes, backupCount=backup_count, encoding="utf-8")
    fh.setLevel(level)
    fh.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
    root.addHandler(fh)
