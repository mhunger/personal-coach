# Personal Coach — Project Context

## Purpose

A local, containerised personal coach website for training, nutrition, meal prep, and shopping. Built around the reality of a demanding full-time job, marriage, and friendships — the coach is meant to feel like a trusted editorial advisor, not a hype machine. Claude is the brain; a Java backend owns domain data; Flutter web is the surface.

## Tech Stack

- **Backend:** Java 21, Spring Boot 3.3+, Spring Data JPA, Flyway, MySQL Connector/J, Lombok.
- **AI Sidecar:** Python 3.12, Claude Agent SDK, FastAPI + uvicorn. Owns all Claude traffic and all skill usage. The Java backend never calls Anthropic directly.
- **DB:** MySQL 8.
- **Frontend:** Flutter web — clean architecture (`domain/` · `data/` · `presentation/`) per feature. Fonts: Fraunces (display + body), IBM Plex Sans (UI chrome), IBM Plex Mono (numerics). No Inter.
- **Container:** Docker + docker-compose (three services: `mysql`, `backend`, `coach-sidecar`).

## Repo Layout (trimmed)

```
personal-coach/
├── CLAUDE.md
├── README.md
├── .env.example
├── docker-compose.yml
├── backend/                # Spring Boot
│   └── src/main/java/com/personalcoach/{profile,schedule,training,coach,config}/
├── coach-sidecar/          # Python + Claude Agent SDK
│   └── src/coach/{main.py,agent.py,components.py,tools.py}
└── frontend/               # Flutter web
    └── lib/{core/{theme,api}, features/{profile,today,coach,training,shared}}
```

## How to Run

```
cp .env.example .env         # fill in ANTHROPIC_API_KEY
docker compose up --build    # → http://localhost:8080
```

## Domain Model (v1)

- **UserProfile** (single row, seeded on first run) — physical, goals, constraints, lifestyle, equipment, training preferences.
- **WeeklySchedule** — one row per ISO week; free-text notes + JSON `busyBlocks` (known commitments).
- **TrainingPlan** + **TrainingSession** — a week of planned workouts with rationale.
- **CoachConversation** + **CoachMessage** — chat history. Messages persist **component JSON**, not prose (see Generative UI).

Nutrition / recipes / shopping are deferred; add when we pick them up.

## Frontend Design — "Private Edition"

The UI is a personal magazine, published live by the coach as your editor. Desktop: two panes — Briefing (left) · Edition stream (right, persistent). Mobile: Edition is a bottom sheet.

- Palette: Paper `#F5F1E8` · Card inset `#EDE6D5` · Ink `#1A1A1A` · Oxblood `#8C2727` (CTAs, editor's marks, drop caps) · Sage `#7A8C6A` (done) · Mustard `#E8D98A` (streak) · Rule-gray `#C8C1AE`.
- Signature details: SVG paper-grain overlay, oxblood L-corner marks on every card, edition date in the margin (Fraunces italic), double-rule dividers, oxblood drop caps on pull quotes, staggered component reveal (280ms / 80ms stagger / 12px rise).

## Generative UI — The Principle

> The coach does not reply in prose. It publishes structured components into a private edition. Every domain object — recipe, session, shopping list, metric, suggestion, quote — has a dedicated type in the component registry. Text is one component among many, never the default. When a new domain concept emerges, add it to the registry; don't let the coach narrate around the gap.

**Mechanics.** The agent replies by calling a single tool `render(components)` whose `input_schema` is a discriminated union over the registry. Schema validation replaces "please format nicely" prompts. Persisted `CoachMessage.components` is this JSON.

**v1 registry (4 types):** `TextBlock`, `SuggestionCard`, `TrainingSessionCard`, `RecipeCard`. Adding a type = new union branch in `coach-sidecar/src/coach/components.py` + new widget under `frontend/lib/features/coach/presentation/components/`.

## Agent (sidecar)

**Persona.** Pragmatic personal coach. Respects a demanding full-time job, marriage, friendships. Evidence-based, concise, motivating without being preachy. Replies only via `render`.

**Tools.** `render(components)`, `get_profile()`, `get_schedule(iso_week)`, `generate_training_plan(iso_week)`, `sync_calendar(iso_week)` (invokes `gws` CLI).

**Skills.** Host `~/.claude/skills` and `~/.claude/plugins` are mounted read-only into the sidecar; project-local skills live in `coach-sidecar/skills/`. Agent SDK auto-discovers both. Skills needing CLIs (e.g., `gws-*`) require the CLI preinstalled in the sidecar image — no skill whitelist for now.

## Conventions

- **Language.** English throughout — code, comments, commits, docs.
- **Backend.** Feature packages (`profile/`, `schedule/`, `training/`, `coach/`). JPA + Flyway. No direct Anthropic calls — always through the sidecar.
- **Frontend.** Clean architecture per feature (`domain/` · `data/` · `presentation/`). No Inter/Roboto/system fonts — use the named Fraunces + Plex stack via `google_fonts`.
- **Sidecar.** All structured output via the `render` tool. If the coach needs to express something new, add a component type before tweaking prompts.
- **Auth.** Single user, no auth. Local only.
- **Secrets.** `.env` only, never committed.

## Filesystem Scope (critical)

- Stay inside `/Users/mhunger/development/personal-coach/`. Do **not** navigate to or scan parent directories.
- The global `~/.claude/CLAUDE.md` rule applies here too — treat it as the top priority.

## Verification Snapshot (v1)

- `docker compose up --build` brings up all three containers.
- `http://localhost:8080/` renders the Flutter app in the editorial aesthetic.
- Today screen auto-populates with 2–3 `SuggestionCard`s from the sidecar on load.
- Chat round-trips; messages persist as component JSON across reloads.
- "Plan my training for next week" → coach calls `generate_training_plan`, publishes `TrainingSessionCard`s.
- "Sync my calendar" → sidecar invokes `gws`, `WeeklySchedule` is populated.
