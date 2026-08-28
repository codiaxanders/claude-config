---
name: feedback_external_editor_file_races
description: When editing a file the user may have open in Emacs, always re-read it immediately before editing and commit to git as checkpoints — don't trust in-context knowledge of file state
metadata:
  type: feedback
---

Always re-read a file fresh, immediately before editing it, when there's
any chance it changed outside the current tool-call sequence — especially
when the user keeps it open in Emacs. Don't rely on "file state is current
in your context" from a few turns back as a substitute for a fresh Read.

**Why:** In a session working on `~/cdx/zipfer/zipfer.md`, an Emacs
autosave/lock file (`#zipfer.md#`, `.#zipfer.md`) was present from the
start, showing the user had the file open for live editing. Claude made a
sequence of targeted Edit calls based on an earlier Read rather than
re-reading right before editing. The user later reported that text they
had manually deleted reappeared in the file — most likely because an
Emacs buffer save (with a stale, pre-edit buffer) overwrote Claude's
on-disk changes, or Claude edited against a stale snapshot. The user's
reaction was sharp: "du MÅSTE hålla koll på vad du gör och inte slarva"
(you MUST keep track of what you're doing and not be careless). No git
commits existed yet, so there was no checkpoint to diff against or
recover from — compounding the problem.

**How to apply:**
- Before editing a file that could be open in another editor (check for
  editor lock/autosave files, or just ask if unsure), Read it fresh
  immediately before the edit, not several turns earlier.
- When a git repo exists specifically for version control of a working
  document (as the user set up here), commit after each meaningful,
  user-approved edit round — it costs nothing and turns "something got
  clobbered" into a two-second `git diff`/`git checkout` fix instead of
  a forensic mystery and an angry user.
- If something unexpected appears/disappears in a file, say so plainly,
  investigate the actual mechanism (external editor race, missing
  checkpoint) rather than guessing or being defensive, and propose the
  concrete fix (reload editor buffer, commit baseline) — see
  [[zipfer-server-project]] for the specific incident context.
