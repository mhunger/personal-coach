"""FastAPI entrypoint for the coach sidecar.

v1 surfaces a single endpoint: POST /coach/suggestions.
Step 9 adds /coach/chat and conversation persistence.
"""

from __future__ import annotations

import logging
from datetime import datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .agent import generate_suggestions
from .backend_client import BackendClient
from .iso_week import iso_week_string

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("coach.sidecar")

app = FastAPI(title="Personal Coach Sidecar", version="0.1.0")
backend = BackendClient()


class SuggestionsRequest(BaseModel):
    context: str = "today"


class SuggestionsResponse(BaseModel):
    components: list[dict]


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/coach/suggestions", response_model=SuggestionsResponse)
async def suggestions(req: SuggestionsRequest) -> SuggestionsResponse:
    now = datetime.now()
    try:
        profile = await backend.get_profile()
    except Exception as exc:  # noqa: BLE001 — log and continue with partial context.
        log.warning("Failed to load profile: %s", exc)
        profile = {}
    try:
        schedule = await backend.get_schedule(iso_week_string(now))
    except Exception as exc:  # noqa: BLE001
        log.warning("Failed to load schedule: %s", exc)
        schedule = {}

    try:
        components = await generate_suggestions(
            context=req.context,
            snapshot={"profile": profile, "schedule": schedule, "now": now.isoformat()},
        )
    except Exception as exc:  # noqa: BLE001
        log.exception("Agent call failed")
        raise HTTPException(status_code=502, detail=f"Coach unavailable: {exc}") from exc

    return SuggestionsResponse(components=components)
