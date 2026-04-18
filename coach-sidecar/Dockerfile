# syntax=docker/dockerfile:1.7
# Build context = ./coach-sidecar.
# Ships Python + Node (for the `claude` CLI that the Agent SDK drives under
# the hood). Host ~/.claude/skills and ~/.claude/plugins are mounted into
# /root/.claude/... by docker-compose so the CLI auto-discovers them.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive \
    CLAUDE_DISABLE_AUTO_UPDATE=1

WORKDIR /app

# System deps + Node 20 (for the claude CLI).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git \
 && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Claude Code CLI — required by the Agent SDK.
RUN npm install -g @anthropic-ai/claude-code

# Python dependencies.
RUN pip install --no-cache-dir \
        "claude-agent-sdk>=0.1.63" \
        "fastapi>=0.115" \
        "uvicorn[standard]>=0.32" \
        "httpx>=0.27" \
        "pydantic>=2.9"

# Source + project-local skills.
COPY src/ /app/src/
COPY skills/ /app/skills/

ENV PYTHONPATH=/app/src

EXPOSE 8000
CMD ["uvicorn", "coach.main:app", "--host", "0.0.0.0", "--port", "8000"]
