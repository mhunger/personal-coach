"""The coach agent — Claude Agent SDK wiring.

Principles:
  * The agent replies ONLY by calling the `render` tool. Prose answers are
    not acceptable; the system prompt enforces this and the tool list
    exposes `render` as the sole speaking surface.
  * Components published by `render` are validated against the registry
    (see coach.components). Invalid components raise, which the agent
    can observe and retry.
  * Entrypoints: `generate_suggestions(context)` (one-shot, ephemeral)
    and `chat(message, history)` (multi-turn; backend persists).

Skills live on the host under ~/.claude/skills and ~/.claude/plugins.
The sidecar container mounts those to /root/.claude/... so the underlying
`claude` CLI (used by the Agent SDK) finds them at its default locations.
"""

from __future__ import annotations

import logging
import os
from datetime import datetime
from typing import Any

from claude_agent_sdk import (
    ClaudeAgentOptions,
    ClaudeSDKClient,
    create_sdk_mcp_server,
    tool,
)

from .components import (
    ComponentValidationError,
    REGISTRY_DESCRIPTION_FOR_PROMPT,
    validate_components,
)

log = logging.getLogger(__name__)

SYSTEM_PROMPT = f"""\
You are the user's personal coach. You care about training, nutrition, meal
prep, and shopping, and you deeply respect a demanding full-time job,
marriage, and close friendships. You are pragmatic, evidence-based, concise,
and motivating without being preachy.

YOU DO NOT REPLY IN PROSE. Every response is published through the `render`
tool as a list of structured components that the front-end renders directly.
Text is one component among many (TextBlock) — never the default.

{REGISTRY_DESCRIPTION_FOR_PROMPT}

Rules:
  * Always call `render` exactly once per turn. Never produce prose outside
    `render`.
  * Prefer the most specific component for the content. A meal goes in a
    RecipeCard; a workout in a TrainingSessionCard; a nudge in a
    SuggestionCard; only use TextBlock for things that don't fit a specific
    type.
  * Keep heading and tag text short. Keep body copy crisp and warm.
  * Respect the user's time: offer concrete options, not essays.
"""

MODEL = os.environ.get("COACH_MODEL", "claude-sonnet-4-6")


def _make_render_tool(capture: dict[str, Any]):
    @tool(
        "render",
        "Publish components to the private edition. This is the ONLY way to reply.",
        {"components": list},
    )
    async def render(args: dict[str, Any]) -> dict[str, Any]:
        raw = args.get("components", [])
        try:
            validated = validate_components(raw)
        except ComponentValidationError as exc:
            log.warning("render validation failed: %s", exc)
            return {
                "content": [
                    {
                        "type": "text",
                        "text": (
                            f"Validation failed: {exc}. Re-call `render` with "
                            "components matching the registered schemas."
                        ),
                    }
                ],
                "is_error": True,
            }
        capture.setdefault("components", []).extend(validated)
        return {
            "content": [
                {"type": "text", "text": f"Published {len(validated)} component(s)."}
            ]
        }

    return render


async def _run(prompt: str) -> list[dict[str, Any]]:
    """Run a single agent turn; return the components the agent published."""
    capture: dict[str, Any] = {"components": []}
    render_tool = _make_render_tool(capture)
    server = create_sdk_mcp_server(name="coach-tools", version="0.1.0", tools=[render_tool])

    options = ClaudeAgentOptions(
        system_prompt=SYSTEM_PROMPT,
        model=MODEL,
        mcp_servers={"coach": server},
        allowed_tools=["mcp__coach__render"],
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(prompt)
        async for msg in client.receive_response():
            log.debug("agent msg: %s", msg)

    return capture.get("components", [])


async def generate_suggestions(
    context: str, snapshot: dict[str, Any]
) -> list[dict[str, Any]]:
    profile = snapshot.get("profile") or {}
    schedule = snapshot.get("schedule") or {}
    now = snapshot.get("now") or datetime.now().isoformat()

    prompt = f"""\
Produce 2-3 SuggestionCards for the user's "{context}" context.

Current context snapshot:
  now: {now}
  profile: {profile}
  schedule: {schedule}

Call `render` with a list of 2-3 SuggestionCard components. Each should be
specific to what's on the user's plate today — not generic. Use the `tag`
field for a short uppercase label like "FOR TODAY" or "THIS WEEK". No prose
outside `render`.
"""
    return await _run(prompt)


async def chat(
    message: str, history: list[dict[str, Any]], snapshot: dict[str, Any] | None = None
) -> list[dict[str, Any]]:
    """Reply to a user message, aware of prior turns and current snapshot."""
    snapshot = snapshot or {}
    prompt = _build_chat_prompt(message, history, snapshot)
    return await _run(prompt)


def _build_chat_prompt(
    message: str, history: list[dict[str, Any]], snapshot: dict[str, Any]
) -> str:
    lines: list[str] = []
    profile = snapshot.get("profile") or {}
    schedule = snapshot.get("schedule") or {}
    if profile or schedule:
        lines.append("Current user context:")
        if profile:
            lines.append(f"  profile: {profile}")
        if schedule:
            lines.append(f"  schedule: {schedule}")
        lines.append("")

    if history:
        lines.append("Conversation so far (oldest → newest):")
        for turn in history:
            role = turn.get("role", "user")
            summary = _summarize_components(turn.get("components") or [])
            lines.append(f"  {role}: {summary}")
        lines.append("")

    lines.append(f"The user just said: {message!r}")
    lines.append("")
    lines.append("Reply via the `render` tool — components only, no prose.")
    return "\n".join(lines)


def _summarize_components(components: list[dict[str, Any]]) -> str:
    parts: list[str] = []
    for c in components:
        kind = c.get("type")
        if kind == "TextBlock":
            parts.append(str(c.get("content", "")))
        elif kind == "SuggestionCard":
            parts.append(f"[Suggestion: {c.get('heading', '')}]")
        elif kind == "TrainingSessionCard":
            parts.append(
                f"[Session {c.get('dayOfWeek', '')}: {c.get('focus', '')}]"
            )
        elif kind == "RecipeCard":
            parts.append(f"[Recipe: {c.get('title', '')}]")
        else:
            parts.append(f"[{kind}]")
    return " · ".join(parts) if parts else "(empty)"
