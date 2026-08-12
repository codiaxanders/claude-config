---
name: feedback-check-synced-memory-every-session
description: "Always check the synced $HOME memory folder at session start, regardless of session cwd, before claiming 'I have nothing on this'"
metadata:
  node_type: memory
  type: feedback
---

Always read `~/.claude/projects/-home-anders/memory/MEMORY.md` (the cross-machine synced memory index, backed by `~/github/codiaxanders/claude-config/memory/`) early in any session, even when the session's own cwd is something else entirely and its local per-cwd memory folder is empty.

**Why:** on 2026-08-12, in a session started in `/home/anders/tmp`, Claude only checked the local per-cwd memory folder (`~/.claude/projects/-home-anders-tmp/memory/`), found it empty, and told the user nothing was known about their `claude -p "ping"` cron job. The actual answer already existed in the synced memory ([[user_claude_usage_window_ping]]) but in the `$HOME`-scoped folder, which sessions outside `$HOME` don't check automatically. This forced the user to explicitly redirect Claude to the right directory instead of getting the already-known answer immediately.

**How to apply:** this is now also codified as a standing rule in the global `~/.claude/CLAUDE.md` (`## Memory system` section), so it should be enforced by default rather than needing to be rediscovered per session. Before saying "I don't have anything on X" or asking the user a question that general/user/feedback/reference memory might already answer, check the synced index first. See also [[memory_sync_scope_rule]] (the write-side counterpart of this rule) and [[claude_config_repo_and_sync]].
