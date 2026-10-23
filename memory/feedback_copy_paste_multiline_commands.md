---
name: feedback-copy-paste-multiline-commands
description: Pasteable commands must have every line under ~70 chars, split with backslash continuation — terminal wrapping breaks long lines when copied
metadata:
  type: feedback
---

When giving Anders shell commands to copy-paste from the terminal, every line in the code block must be short (under ~70 characters). Split any longer command with ` \` at the end of each continued line, breaking between arguments (never inside a quoted string). When a block contains several separate commands, say explicitly that they are separate steps.

**Why:** The terminal hard-wraps long lines; copying a wrapped line inserts line breaks that split the command. A single long "one-liner" is just as broken as an unjoined multi-line command. Anders had to point this out twice (2026-10-23).

**How to apply:** Before sending any pasteable block, check line lengths. Commands with long nested quoting: restructure (e.g. variables, heredoc, a script in the repo) so they can be split safely.
