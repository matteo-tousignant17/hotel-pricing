"""
Factor calculator — stub for Stage 4.
Will compute individual factor adjustments using DB-stored weights
from pricing_factor_weights, season_definitions, and lead_time_tiers.
"""


def get_season_index(month: int, day: int, market: str = "denver") -> float:
    """Returns demand_index for a given date. Stub uses hardcoded Denver seasons."""
    if (month == 12 and day >= 15) or month in (1, 2) or (month == 3 and day <= 10):
        return 1.30
    if (month == 6 and day >= 15) or month in (7, 8):
        return 1.25
    if month in (3, 4):
        return 1.10
    if month in (9, 10):
        return 1.05
    if month == 11 or (month == 12 and day < 15):
        return 0.85
    return 1.00


def get_lead_time_multiplier(days: int) -> float:
    """Returns rate multiplier based on booking window. Stub matches seed data."""
    if days <= 1:
        return 1.30
    if days <= 6:
        return 1.15
    if days <= 13:
        return 1.05
    if days <= 29:
        return 1.00
    if days <= 59:
        return 0.95
    if days <= 89:
        return 0.90
    return 0.85
