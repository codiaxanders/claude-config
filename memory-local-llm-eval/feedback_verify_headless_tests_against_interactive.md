---
name: feedback-verify-headless-tests-against-interactive
description: "Headless claude -p tests don't exercise every interactive code path — say so explicitly and have the user spot-check"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5038e60c-c6dd-4aab-bd99-6caf418ea441
  modified: 2026-08-09T19:49:04.790Z
---

When validating how Claude Code behaves in some environment (e.g. against a local LLM backend), running many headless `claude -p ...` tests is efficient but not sufficient on its own — some behavior (confirmed: `ANTHROPIC_SMALL_FAST_MODEL` usage at session start, likely session-title generation) only happens in a real interactive session and never fires in headless/print mode.

**Why:** discovered 2026-08-09 in [[project-claude-code-automode-local-backend]] — ran a minimal 1-turn headless probe AND a real 33-turn headless coding session, both showed zero small/fast-model usage in `modelUsage`. The user ran their own normal interactive session and the small/fast model loaded immediately at startup. The user explicitly called this out: "you should have gotten the same result, otherwise you haven't heard what I said" — a fair correction, since I'd been treating headless results as if they fully validated the interactive experience the user actually cares about.

**How to apply:** when reporting headless-test results as validation of "it'll work when you run it," explicitly flag which code paths headless mode cannot exercise (anything session-startup/UI-tied), and hand the user a concrete, specific thing to watch for in their own interactive run rather than assuming headless coverage is complete. Don't wait for the user to catch the gap — surface it proactively next time.
