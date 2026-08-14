---
name: feedback-handoff-md-lifecycle
description: HANDOFF.md files are ephemeral session-to-session notes, not persistent project docs
metadata:
  type: feedback
---

A `HANDOFF.md` found at session start (injected via system-reminder) is a one-shot
note from the previous session, not a file that should persist in the project
tree. It gets removed automatically once read into context — its presence
after that point signals something went wrong, not that it's fine to leave
there.

**Why:** Anders was surprised to see `HANDOFF.md` still present after the
prior session ended — expected it to be gone by the time a new session reads
it in, since its only job is to carry context across the session boundary.

**How to apply:** Don't treat `HANDOFF.md` as a durable artifact to maintain,
update, or leave in `git status`/untracked-files output. If it's still present
after being read, it's worth a quick double-check whether cleanup failed,
rather than assuming it's meant to stick around.

**Mandatory disclosure:** Every time a HANDOFF.md is loaded at session start,
the very first reply in that session must explicitly say a handoff was found
and loaded, then give a short summary of its Status line and overall project
status (plus any warnings). Anders explicitly repeated this instruction on
2026-08-14 after feeling it wasn't being done reliably — treat it as a hard
requirement, not something to do only when it seems relevant.
