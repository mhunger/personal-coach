"""FastAPI entrypoint for the coach sidecar.

v1 surfaces two endpoints:
  POST /coach/suggestions — one-shot contextual nudges.
  POST /coach/chat        — multi-turn chat; backend persists.
"""

from __future__ import annotations

import logging
from datetime import datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from .agent import chat, generate_suggestions
from .backend_client import BackendClient
from .iso_week import iso_week_string

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("coach.sidecar")

app = FastAPI(title="Personal Coach Sidecar", version="0.1.0")
backend = BackendClient()


class SuggestionsRequest(BaseModel):
    context: str = "today"


class ComponentStreamResponse(BaseModel):
    components: list[dict]


class ChatRequest(BaseModel):
    message: str
    history: list[dict] = []


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/coach/suggestions", response_model=ComponentStreamResponse)
async def suggestions(req: SuggestionsRequest) -> ComponentStreamResponse:
    snapshot = await _load_context_snapshot()
    try:
        components = await generate_suggestions(context=req.context, snapshot=snapshot)
    except Exception as exc:  # noqa: BLE001
        log.exception("Agent call failed")
        raise HTTPException(status_code=502, detail=f"Coach unavailable: {exc}") from exc
    return ComponentStreamResponse(components=components)


@app.post("/coach/chat", response_model=ComponentStreamResponse)
async def chat_turn(req: ChatRequest) -> ComponentStreamResponse:
    snapshot = await _load_context_snapshot()
    try:
        components = await chat(
            message=req.message,
            history=req.history,
            snapshot=snapshot,
        )
    except Exception as exc:  # noqa: BLE001
        log.exception("Chat call failed")
        raise HTTPException(status_code=502, detail=f"Coach unavailable: {exc}") from exc
    return ComponentStreamResponse(components=components)


async def _load_context_snapshot() -> dict:
    now = datetime.now()
    try:
        profile = await backend.get_profile()
    except Exception as exc:  # noqa: BLE001
        log.warning("Failed to load profile: %s", exc)
        profile = {}
    try:
        schedule = await backend.get_schedule(iso_week_string(now))
    except Exception as exc:  # noqa: BLE001
        log.warning("Failed to load schedule: %s", exc)
        schedule = {}
    return {"profile": profile, "schedule": schedule, "now": now.isoformat()}
