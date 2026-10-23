---
name: outsource-commands
description: /outsource, /intake, /outsource-scan exist for handing generic non-confidential jobs to opencode or another Claude account; not yet test-run
metadata:
  type: project
---

Commands in claude-config/commands/ (commit 3270315, 2026-09-28), design in
claude-config/notes/outsource-intake-design.md. Jobs live in
~/outsource/<OS-YYYYMMDD-hex>-<slug>/ (TASK.md out, LOCAL.md never sent,
RESULT/ in). Confidentiality is judged case by case, erring cautious, and
flagged to Anders before export; no blocklist file.

**Why:** save tokens on the primary account; the receiving account/model is
not controlled, so nothing about Codiax, customers or their systems may leave.

**How to apply:** first job OS-20260928-fa8cd1 (lightweight project-planning
tools) written 2026-09-28, to run in opencode + local Ollama/Qwen3-Coder;
check ~/outsource/*/LOCAL.md for status and /intake it when RESULT/ exists.
