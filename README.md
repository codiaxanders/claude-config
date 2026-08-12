# claude-config

Personal configuration for [Claude Code](https://claude.ai/code) — Anthropic's AI coding assistant.

This repo contains the global setup that applies across all projects and machines.
It is symlinked into `~/.claude/` via `setup.sh`.

## Contents

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Global instructions and behavioral rules for Claude Code |
| `settings.json` | Global Claude Code settings (permissions, hooks, etc.) |
| `setup.sh` | Bootstrap script — symlinks this repo into `~/.claude/` |
| `hooks/pre-commit-check.sh` | Git hook that blocks accidental AI-related content in commits |
| `hooks/session-start-handoff-check.sh` | Surfaces a project's `HANDOFF.md` at session start, if one exists |
| `templates/general/CLAUDE.md` | Starting template for non-Yocto project `CLAUDE.md` files |
| `templates/yocto/CLAUDE.md` | Starting template for Yocto/OpenEmbedded project `CLAUDE.md` files |
| `agents/` | Custom agent definitions |
| `commands/handoff.md` | `/handoff` command — writes/commits a project's `HANDOFF.md` session note |

## Setup

```sh
git clone <repo-url> ~/github/codiaxanders/claude-config
cd ~/github/codiaxanders/claude-config
./setup.sh
```

## Key behaviors

- **Stealth/Visible mode** — at the start of each session, Claude asks whether AI traces are acceptable in the project
- **Pre-commit hook** — scans staged content for AI-related keywords and blocks suspicious commits
- **Project templates** — `CLAUDE.md` templates for general and Yocto projects ensure consistent onboarding
- **Session handoff** — run `/handoff` in a git project to write and commit a `HANDOFF.md` status note; any later session started in that directory (on any machine, once pulled) picks it up automatically at startup
