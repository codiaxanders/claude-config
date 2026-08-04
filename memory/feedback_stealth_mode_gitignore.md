---
name: feedback-stealth-mode-gitignore
description: In stealth mode, never add .claude/ (or similar) to .gitignore — the entry itself is a visible trace of AI usage
metadata:
  node_type: memory
  type: feedback
---

Do not add `.claude/`, `CLAUDE.md`, or similar entries to `.gitignore` when operating in stealth mode (per the global CLAUDE.md project-onboarding rules), even as a precaution against a directory that doesn't exist yet.

**Why:** The global CLAUDE.md instructs suggesting a `.gitignore` entry for `.claude/` in stealth mode as a safety net. But a `.gitignore` line naming `.claude/` is itself a visible trace — anyone reading the file sees the project was set up for Claude Code, which directly contradicts stealth mode's goal of leaving zero AI-related traces. The user caught this contradiction (in the atlas-demo project) and confirmed it should apply everywhere, not just that one project.

**How to apply:** In any project, in stealth mode, don't touch `.gitignore` for AI-tool-related entries at all, even proactively/preemptively. If a `.claude/` directory is ever actually created mid-session in stealth mode, handle it by not committing it (or removing it) rather than by adding a gitignore rule that advertises its existence.
