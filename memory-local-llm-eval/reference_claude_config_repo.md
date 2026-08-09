---
name: reference-claude-config-repo
description: Location of local-LLM Claude Code startup scripts and ollama setup docs
metadata: 
  node_type: memory
  type: reference
  originSessionId: 5038e60c-c6dd-4aab-bd99-6caf418ea441
  modified: 2026-08-08T13:05:15.890Z
---

Startup scripts and ollama setup notes for running Claude Code against local models live in `~/github/codiaxanders/claude-config/`:

- `start_claude_with_local_llm.sh` — sets `ANTHROPIC_BASE_URL`, `ANTHROPIC_MODEL`, `ANTHROPIC_SMALL_FAST_MODEL`, then launches `claude`. Contains inline comments logging which models were tried and how they performed.
- `start_claude_with_gemini_flash_free.sh` — alternate start script for Gemini Flash free tier.
- `notes/ollama-kilocode-setup.md` — full ollama systemd setup (env vars, Modelfile context-baking, VRAM budget) for host "ws1", plus Kilo Code VS Code extension provider config. Written for a different model pair (`gemma4:e4b-128k` + `qwen2.5-coder:3b-4k`) than the current Claude Code default below, so treat VRAM numbers there as stale relative to [[project_local_llm_eval]].

See [[project_local_llm_eval]] for the current model choice and reasoning.
