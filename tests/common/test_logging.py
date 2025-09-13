import logging

from apps.common.src.logging import get_logger


def test_get_logger_reuse():
    logger1 = get_logger("rankalpha-test")
    assert isinstance(logger1, logging.Logger)
    logger2 = get_logger("rankalpha-test")
    assert logger1 is logger2
