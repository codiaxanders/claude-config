---
name: memory-sync-scope-rule
description: "Where to write new memories: synced cross-machine store vs. the current session's local project memory folder"
metadata:
  node_type: memory
  type: feedback
---

Auto-memory is stored per-machine, keyed by the exact cwd a session started in (`~/.claude/projects/<hash-of-cwd>/memory/`). Only the folder for cwd == `$HOME` is synced across the user's machines, via `[[claude-config-repo-and-sync]]`. Memory saved from a session started anywhere else stays stuck on that one machine unless deliberately written to the synced folder instead.

**Why:** the user works across multiple computers and wants any memory that's actually about *them* (not about one specific local codebase) to follow them everywhere, without needing to remember to start those sessions from `$HOME`.

**How to apply:** when about to save a new memory, judge whether it's about the user/their working style in general (types `user`, `feedback`, `reference`) versus tied to the specific codebase/project the current session happens to be in (type `project`). If it's clearly general, write it directly into the synced memory directory (`~/github/codiaxanders/claude-config/memory/`, i.e. `~/.claude/projects/-home-anders/memory/`) regardless of the session's actual cwd, and update that directory's `MEMORY.md` instead of the local one. If it's ambiguous whether something is repo-specific or generally applicable, ask the user rather than assuming either way — don't silently default to local-only or silently promote something to global.
