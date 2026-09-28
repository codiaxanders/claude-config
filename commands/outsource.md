---
description: Package a generic, non-confidential task as a self-contained job for another agent (opencode, or Claude on another account) to save tokens here. Nothing is written until the user approves the job text.
argument-hint: <what should be done>
allowed-tools: Bash(date *), Bash(openssl rand *), Bash(mkdir -p ~/outsource/*), Bash(ls *)
disable-model-invocation: true
---

Package this task as an outsourced job: $ARGUMENTS

The design is in `~/github/codiaxanders/claude-config/notes/outsource-intake-design.md`.
The job will run on an account or model that is not controlled the way this
one is, so the only file that leaves the machine, `TASK.md`, must contain
nothing confidential.

1. **Suitability.** Decide whether the task can be done without confidential
   context: anything about Codiax, its customers, customers' systems, or
   internal projects. If it cannot be made generic without losing what the
   task is for, say so, explain why, and stop.
2. **Draft `TASK.md`** in the conversation, in English, self-contained and
   usable by any agent. It must not refer to files in the user's
   repositories; any context it needs is written into it in generic form.
   Use this structure:
   ```
   Job ID: <ID>

   # <title>

   ## Goal
   ## Background
   ## Constraints
   - Work in an empty directory created for this job.
   - Run tools through Docker; do not install packages system-wide.
   - Use no secrets or credentials, and do not ask for any.
   - <task-specific constraints>
   ## Deliverables
   ## Acceptance criteria
   <numbered, each checkable>
   ## Return format
   Put everything in a directory named `RESULT/`. `RESULT/SUMMARY.md` must
   start with the line `Job ID: <ID>` and then cover: what was done,
   commands run, tool versions, the outcome for each acceptance criterion by
   number, and problems met. Keep it short.
   ```
   Leave `<ID>` as a placeholder in the draft.
3. **Confidentiality review.** Judge the draft yourself, erring on the
   cautious side. Show the full draft, then a list of everything that was
   genericised or is doubtful, with the reason for each. Look for:
   - company, product, customer and people names;
   - hardware-and-purpose combinations that could identify a customer;
   - internal paths, host names, repository names;
   - details specific enough to reveal a project.
   If nothing is doubtful, say that explicitly. Then stop and wait: discuss
   with the user and revise until they approve the text.
4. **Write the job** only after approval:
   - ID: `OS-$(date +%Y%m%d)-$(openssl rand -hex 3)`.
   - Slug: a few lowercase words from the title, hyphenated, generic.
   - Create `~/outsource/<ID>-<slug>/` and write `TASK.md` there with the
     real ID in place of the placeholder (both occurrences).
   - Write `LOCAL.md` next to it:
     ```
     Job ID: <ID>
     Source project: <repo root, or cwd if not a repo>
     Purpose: <the real purpose, one or two lines>
     Feeds into: <what the result is meant for>
     Status: out
     ```
   - Never put anything from `LOCAL.md` into `TASK.md`.
5. Tell the user the job ID and the path of `TASK.md`, and that the result
   goes back into `~/outsource/<ID>-<slug>/RESULT/` for `/intake <ID>`.
