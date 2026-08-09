---
name: project-crawler-se-indexer
description: The .se URL indexer crawler test project used to stress-test Claude Code against local Ollama models
metadata: 
  node_type: memory
  type: project
  originSessionId: 5038e60c-c6dd-4aab-bd99-6caf418ea441
  modified: 2026-08-09T19:49:16.960Z
---

Test project at `~/workspace/claude_tests/crawler_test_procject_w_local_llm_for_claude` (host ws1) — a from-scratch web crawler meant to build an exhaustive index of `.se` URLs, used mainly as a real workload to validate the [[project-local-llm-eval]] local-LLM Claude Code setup, not (yet) a project with independent priority of its own.

Stack: Python 3, asyncio/aiohttp, FastAPI Seed API, Redis (AOF) + SQLite (WAL) storage, per-domain rate limiting, URLs-only (no page content stored). Mode: VISIBLE (AI traces allowed, has its own CLAUDE.md). Built via superpowers `executing-plans` off specs/plans under `docs/superpowers/`.

**Why it matters for the LLM eval:** this project is what first surfaced the Ollama concurrency bug, and later (2026-08-09) the real remaining blocker — Claude Code's own auto-mode Bash-safety classifier failing against the slow local model. Full mechanism and fixes: [[project-claude-code-automode-local-backend]]. The earlier note that subagents don't work against Ollama was superseded 2026-08-09 — `CLAUDE_CODE_SUBAGENT_MODEL` fixes that.

**Status as of 2026-08-09:** Plans 1 (Infrastructure & Shared Core), 2 (Seed API), and 3 (Crawler Worker) are all implemented and verified — confirmed via two independent full end-to-end headless runs (Plan 2 run: hit the venv classifier wall, degraded gracefully; Plan 3 run after adding a CLAUDE.md no-venv rule: 46 turns, zero venv blocks, real tests passing). Project can now build its remaining steps without the infra getting in the way. Next actual step per its own `PROJECT_STATUS.md` would be final validation/tuning.

**How to apply:** treat this project's own blockers (PROJECT_STATUS.md) as downstream symptoms of the local-LLM infra, not the crawler design — check [[project-claude-code-automode-local-backend]] first before debugging something here that looks like a hang, crash, or skipped step. If `PROJECT_STATUS.md` still shows an old "Bash classifier instability" blocker warning, it's likely stale — verify against actual current test runs before assuming it's still broken.
