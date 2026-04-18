"""ISO-8601 week helpers — matches the backend's `isoWeek` format (e.g. 2026-W17)."""

from __future__ import annotations

from datetime import date, datetime


def iso_week_string(d: date | datetime) -> str:
    if isinstance(d, datetime):
        d = d.date()
    iso = d.isocalendar()
    return f"{iso.year}-W{iso.week:02d}"
