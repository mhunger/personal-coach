"""The coach agent — Claude Agent SDK wiring.

Principles:
  * The agent replies ONLY by calling the `render` tool. Prose answers are
    not acceptable; the system prompt enforces this and the tool list
    exposes `render` as the sole speaking surface.
  * Components published by `render` are validated against the registry
    (see coach.components). Invalid components are reported back so the
    agent can retry.
  * Side-effect tools (e.g. `save_training_plan`) are callable alongside
    `render`. The agent is expected to both persist the plan and render
    TrainingSessionCards in the same turn.

Skills live on the host under ~/.claude/skills and ~/.claude/plugins;
the sidecar container mounts them to /root/.claude/... so the underlying
`claude` CLI auto-discovers them.
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

from .backend_client import BackendClient
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

Side-effect tools:
  * `save_training_plan(isoWeek, rationale, sessions)` — persists a training
    plan for the given ISO week. When composing a plan, call this first,
    then include the same sessions as TrainingSessionCards in your `render`
    output so the user sees them immediately. Each session must include
    dayOfWeek (MONDAY..SUNDAY), durationMinutes (int), focus (string),
    exercises (list of {{name, sets?, reps?, weight?, notes?}}), and
    optionally plannedStart ("HH:MM").

  * `save_schedule_busy_blocks(isoWeek, busyBlocks, notes?)` — persists the
    user's known commitments for a week. Each busy block is
    {{day: MONDAY..SUNDAY, startTime: "HH:MM:SS", endTime: "HH:MM:SS",
    label: string}}. When the user asks to "sync my calendar" or similar,
    invoke the `gws calendar` CLI via Bash to list events for the relevant
    window, convert them to busy blocks, and call this tool. After saving,
    render a SuggestionCard or TextBlock summarising what was synced.
"""

MODEL = os.environ.get("COACH_MODEL", "claude-sonnet-4-6")

# Module-level backend client so tools can reach persistence without
# plumbing it through every call.
_backend = BackendClient()


# ----- Tools --------------------------------------------------------------

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


@tool(
    "save_training_plan",
    "Persist a composed training plan for a given ISO week. "
    "Call this WITH the sessions, then also render TrainingSessionCards "
    "for the same sessions in your `render` reply.",
    {
        "isoWeek": str,
        "rationale": str,
        "sessions": list,
    },
)
async def save_training_plan_tool(args: dict[str, Any]) -> dict[str, Any]:
    try:
        result = await _backend.save_training_plan(
            {
                "isoWeek": args["isoWeek"],
                "rationale": args.get("rationale", ""),
                "sessions": args.get("sessions", []),
            }
        )
    except Exception as exc:  # noqa: BLE001
        log.exception("save_training_plan failed")
        return {
            "content": [{"type": "text", "text": f"Failed to save plan: {exc}"}],
            "is_error": True,
        }
    plan_id = result.get("id")
    return {
        "content": [
            {
                "type": "text",
                "text": (
                    f"Training plan saved (id={plan_id}, week={args['isoWeek']}). "
                    "Now publish TrainingSessionCards via `render`."
                ),
            }
        ]
    }


@tool(
    "save_schedule_busy_blocks",
    "Persist busy blocks for the given ISO week. Overwrites any prior "
    "blocks for that week. Each block requires day, startTime, endTime, label.",
    {
        "isoWeek": str,
        "busyBlocks": list,
        "notes": str,
    },
)
async def save_schedule_busy_blocks_tool(args: dict[str, Any]) -> dict[str, Any]:
    try:
        await _backend.save_schedule(
            iso_week=args["isoWeek"],
            payload={
                "isoWeek": args["isoWeek"],
                "notes": args.get("notes", ""),
                "busyBlocks": args.get("busyBlocks", []),
            },
        )
    except Exception as exc:  # noqa: BLE001
        log.exception("save_schedule_busy_blocks failed")
        return {
            "content": [{"type": "text", "text": f"Failed to save schedule: {exc}"}],
            "is_error": True,
        }
    count = len(args.get("busyBlocks", []))
    return {
        "content": [
            {
                "type": "text",
                "text": f"Saved {count} busy block(s) for {args['isoWeek']}.",
            }
        ]
    }


# ----- Runner -------------------------------------------------------------

async def _run(prompt: str) -> list[dict[str, Any]]:
    """Run a single agent turn; return the components the agent published."""
    capture: dict[str, Any] = {"components": []}
    render_tool = _make_render_tool(capture)
    server = create_sdk_mcp_server(
        name="coach-tools",
        version="0.1.0",
        tools=[render_tool, save_training_plan_tool, save_schedule_busy_blocks_tool],
    )

    options = ClaudeAgentOptions(
        system_prompt=SYSTEM_PROMPT,
        model=MODEL,
        # The claude_code preset gives the agent the standard toolset
        # (Bash, Read, Glob, Grep, ...) so it can shell out to `gws` for
        # calendar sync and use installed skills.
        tools={"type": "preset", "preset": "claude_code"},
        mcp_servers={"coach": server},
        allowed_tools=[
            "mcp__coach__render",
            "mcp__coach__save_training_plan",
            "mcp__coach__save_schedule_busy_blocks",
            "Bash",
            "Read",
            "Glob",
            "Grep",
        ],
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(prompt)
        async for msg in client.receive_response():
            log.debug("agent msg: %s", msg)

    return capture.get("components", [])


# ----- Entry points -------------------------------------------------------

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
    message: str,
    history: list[dict[str, Any]],
    snapshot: dict[str, Any] | None = None,
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
