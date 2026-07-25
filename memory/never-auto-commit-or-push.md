---
name: never-auto-commit-or-push
description: "Global git-safety rule: never commit or push without the user's explicit per-change confirmation, even for config repos"
metadata:
  node_type: memory
  type: feedback
---

Never run `git commit` or `git push` without the user's explicit confirmation for that specific change — this is a standing rule from the user's global `~/.claude/CLAUDE.md`, not just a one-off.

**Why:** stated directly in their global instructions ("Never commit without explicit confirmation from me... Never push without explicit instruction"). A pre-commit hook also enforces the commit side.

**How to apply:** always show the diff/change and ask before committing or pushing — including in `[[claude-config-repo-and-sync]]`, the user's own dotfiles-style config repo. The one deliberate, narrow exception the user approved is the `SessionStart` hook's auto-commit+push of `plugins/installed_plugins.json`/`known_marketplaces.json` specifically — a fixed, always-safe, low-content change, not a general license to auto-commit config edits. When in doubt whether something qualifies as "the same kind of exception," ask rather than assume.
