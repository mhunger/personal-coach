# personal-coach

A local, containerised personal coach for training, nutrition, meal prep, and shopping. Claude is the brain (via a Python Agent-SDK sidecar); a Java Spring Boot backend owns the data; a Flutter web app renders a "Private Edition" — the coach publishes responses as a stream of rendered components, not prose.

## Quick start

Prerequisites: Docker.

```bash
cp .env.example .env                 # fill in ANTHROPIC_API_KEY
docker compose up --build
open http://localhost:8080
```

## Architecture

```
Browser ──▶ Spring Boot ──▶ Python sidecar (Claude Agent SDK + skills + gws CLI)
              │
              └──▶ MySQL
```

Three containers via `docker-compose`: `backend` (Spring Boot + Flutter bundle), `coach-sidecar` (Python + Agent SDK), `mysql`.

## Where things live

- `backend/` — Spring Boot, Java 21. Feature packages: `profile`, `schedule`, `training`, `coach`, `config`.
- `coach-sidecar/` — Python 3.12, Claude Agent SDK, FastAPI. All Claude traffic and skill execution happens here.
- `frontend/` — Flutter web, clean architecture per feature (`domain/` · `data/` · `presentation/`).
- `CLAUDE.md` — full project context and conventions.

## Design — "Private Edition"

Editorial, not neon. Fraunces + IBM Plex; cream paper, ink, oxblood accents. The coach publishes structured components (recipes, training sessions, suggestions) into a live edition — see the *Generative UI* section in `CLAUDE.md`.

## Status

v1 in progress. See `CLAUDE.md` for domain model, component registry, and agent tool surface.
