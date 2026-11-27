---
name: check-branch-before-commit
description: Always verify the checked-out branch right before every git commit/push; the user switches/merges branches between turns
metadata:
  type: feedback
---
Run `git status -sb` (or `git branch --show-current`) immediately before each commit and push, even mid-task.

**Why:** 2026-11-23 the user merged a PR and checked out main between my turns; I committed and pushed a fix straight to origin/main instead of the agreed feature branch.

**How to apply:** never assume the branch from earlier in the session; if it is not the agreed branch, stop and say so before committing.
