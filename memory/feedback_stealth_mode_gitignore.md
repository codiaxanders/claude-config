---
name: feedback-stealth-mode-gitignore
description: In stealth mode, never add .claude/ (or similar) to .gitignore — the entry itself is a visible trace of AI usage
metadata:
  node_type: memory
  type: feedback
---

Do not add `.claude/`, `CLAUDE.md`, or similar entries to `.gitignore` when operating in stealth mode (per the global CLAUDE.md project-onboarding rules), even as a precaution against a directory that doesn't exist yet.

**Why:** The global CLAUDE.md instructs suggesting a `.gitignore` entry for `.claude/` in stealth mode as a safety net. But a `.gitignore` line naming `.claude/` is itself a visible trace — anyone reading the file sees the project was set up for Claude Code, which directly contradicts stealth mode's goal of leaving zero AI-related traces. The user caught this contradiction first in the atlas-demo project, and again in `yoctosystem_guide-1.4` (2026-08-16) — the second time in a row this exact wrong suggestion was made — and confirmed it should apply everywhere, not just one project.

**How to apply:** In any project, the moment stealth mode is confirmed for the session, silently drop the global CLAUDE.md's "suggest adding `.claude/` to `.gitignore`" step entirely — do not offer it, do not ask, do not mention it as an option. Don't touch `.gitignore` for AI-tool-related entries at all, even proactively/preemptively/as a question. If a `.claude/` directory is ever actually created mid-session in stealth mode, handle it by not committing it (or removing it) rather than by adding a gitignore rule that advertises its existence. This is a firm override of that specific global CLAUDE.md step, not a case-by-case judgment call — do not re-raise it even framed as a question.
