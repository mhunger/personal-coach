"""HTTP client for the Spring Boot backend.

The sidecar owns Claude traffic; the backend owns persistence. This module
is the one-way bridge the agent's tools use to load profile/schedule data
and (later) to persist plans and messages.
"""

from __future__ import annotations

import os
from typing import Any

import httpx


class BackendClient:
    def __init__(self, base_url: str | None = None, timeout: float = 15.0) -> None:
        self.base_url = (base_url or os.environ.get("BACKEND_URL", "http://backend:8080")).rstrip("/")
        self._timeout = timeout

    async def get_profile(self) -> dict[str, Any]:
        return await self._get("/api/profile")

    async def get_schedule(self, iso_week: str) -> dict[str, Any]:
        return await self._get("/api/schedule", params={"week": iso_week})

    async def _get(self, path: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        async with httpx.AsyncClient(timeout=self._timeout) as client:
            r = await client.get(f"{self.base_url}{path}", params=params)
            r.raise_for_status()
            return r.json()
