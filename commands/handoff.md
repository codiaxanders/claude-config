---
description: Write a HANDOFF.md in this project summarizing status, what's done, and next steps, so a fresh session started later in this directory can pick up where this one left off.
allowed-tools: Bash(git rev-parse *), Bash(git status *), Bash(git diff *), Bash(git log *), Bash(date *)
disable-model-invocation: true
---

Write a session handoff note for this project so a fresh session started
later in this same directory can continue without the current conversation.

1. Determine the target directory: if `git rev-parse --show-toplevel`
   succeeds, use that repo root; otherwise use the current directory as-is.
   Always proceed — a handoff note is written whether or not this is a git
   repo.
2. Gather current state: if this is a git repo, `git status --short`,
   `git diff --stat`, `git log --oneline -10`, current branch
   (`git rev-parse --abbrev-ref HEAD`) and short commit
   (`git rev-parse --short HEAD`); the existing `HANDOFF.md` if one is
   already there; and everything you already know from this conversation
   about what was done, why, and what's left.
3. Write `<target-directory>/HANDOFF.md`, replacing any previous version.
   If this is a git repo, start the file with an HTML comment metadata
   block (omit it entirely if not a git repo):
   ```
   <!-- HANDOFF_METADATA
   Branch: <current branch>
   Commit: <short commit>
   Timestamp: <UTC ISO 8601, from `date -u +%Y-%m-%dT%H:%M:%SZ`>
   -->
   ```
   Then these sections:
   - **Status** — one line: what state the work is in right now.
   - **Done** — brief bullets of what's been completed (carry forward any
     still-relevant unfinished items from the previous HANDOFF.md).
   - **Next steps** — concrete bullets of what to do next, in order. Include
     relative file paths for the files involved in each step, so the next
     session knows exactly where to start reading instead of searching.
   - **Context** — anything a new session would need but can't get from the
     code or git history alone. Prioritize, in this order: (1) dead ends
     already tried and ruled out — this is what saves the most effort next
     time, since it stops the next session from re-testing a path that's
     already known not to work; (2) non-obvious decisions and why one
     option was chosen over another, especially where it wasn't the
     obvious default; (3) constraints and anything the user said that
     shaped the approach. Capture everything from this conversation that
     isn't already written down anywhere else (not in code, commits, or
     other project files).
   - **Open questions** — anything unresolved the user still needs to weigh
     in on.
   Keep it factual and terse — this replaces re-reading the whole
   conversation, not a transcript of it.
4. Write in plain engineering language, as ordinary session/work notes —
   don't describe this as a machine-authored artifact.
5. Do not stage or commit the file — leave it untracked. It's a one-shot
   note: the next session started in this directory reads it automatically
   and then deletes it, so it only ever applies to that one next session.
6. Tell the user the note was written to `HANDOFF.md` and will be picked up
   and removed automatically the next time a session starts here.
