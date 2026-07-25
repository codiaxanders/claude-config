---
name: claude-config-repo-and-sync
description: "How the user's global Claude Code config is managed and kept in sync across all their machines"
metadata:
  node_type: memory
  type: reference
---

The user's global Claude Code configuration lives in the git repo `~/github/codiaxanders/claude-config` (remote: `git@github.com:codiaxanders/claude-config.git`), not directly in `~/.claude/`.

`~/.claude/{CLAUDE.md,settings.json,hooks,agents,templates,plugins}` are symlinks into that repo, created by `~/github/codiaxanders/claude-config/setup.sh` (idempotent, safe to re-run — backs up real files instead of overwriting, never touches an existing correct symlink). `~/.claude/.credentials.json` is intentionally never in the repo (per-machine secret).

Auto-memory sync: `setup.sh` also symlinks `~/.claude/projects/-home-anders/memory` (the auto-memory folder for sessions whose cwd is `$HOME`) to the repo's `memory/` directory. This is the only cross-machine-synced memory location — memory saved from sessions started in any other directory stays local to that machine and is not synced.

A `SessionStart` hook (`hooks/session-start-check.sh`, wired in `settings.json`) runs at every Claude Code startup and:
- fetches + fast-forward-pulls the repo (never force-merges; warns on divergence instead)
- re-runs `setup.sh`
- auto-commits and auto-pushes ONLY `plugins/installed_plugins.json` and `plugins/known_marketplaces.json` when they've changed — these are tracked on purpose (see commit `b596543`, May 2026) so installed plugins travel between machines, but their `lastUpdated` timestamp churns on every plugin check, so committing them by hand doesn't scale
- for anything else uncommitted or unpushed, only warns — never auto-commits or auto-pushes other config changes, per the user's global git-safety rules ([[never-auto-commit-or-push]])
- always prints a short one-line status via `systemMessage`, even when everything's already in sync

How to apply: when discussing or changing the user's global Claude Code setup, this repo is the source of truth — edit files there (not directly in `~/.claude/`), and remember .credentials.json/most runtime plugin cache stay gitignored (see `plugins/.gitignore`) while the plugin manifests above are a deliberate exception.
