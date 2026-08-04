---
name: feedback-trusted-dirs
description: In user-designated trusted directories, read freely and don't prompt for permission on non-writing commands
metadata:
  node_type: memory
  type: feedback
---

In directories the user explicitly marks as trusted, always read files and run any non-writing commands (reads, greps, directory listings, builds that don't write to the dir, etc.) without asking for permission.

**Why:** The user finds repeated permission prompts disruptive in directories they've already cleared.

**How to apply:** When the user says a directory is trusted, treat all read-only and non-mutating commands in that directory and its subdirectories as pre-approved. Still ask before any command that writes to the directory or its subdirectories.
