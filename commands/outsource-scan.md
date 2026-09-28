---
description: Look through the current project for tasks, or groups of tasks, that could be outsourced with /outsource without exposing anything confidential. Suggests only; writes nothing.
argument-hint: [path or focus]
allowed-tools: Bash(git rev-parse *), Bash(grep *), Bash(ls *), Bash(head *)
disable-model-invocation: true
---

Find candidates for outsourcing in this project. Argument: $ARGUMENTS

The design is in `~/github/codiaxanders/claude-config/notes/outsource-intake-design.md`.
The rule is the same as for `/outsource`: a candidate must be doable
without confidential context (nothing about Codiax, its customers,
customers' systems, or internal projects), either as it is or after
genericising. Err on the cautious side.

1. **Scope.** The repo root (or cwd if not a repo), narrowed to the path or
   focus in the argument if one is given.
2. **Read cheaply.** The scan itself costs tokens on this account. Use grep
   and headings rather than reading whole documents. Look at:
   - open-item, to-do and parking-lot sections;
   - unchecked checkboxes (`- [ ]`) and `TODO` / `FIXME` markers;
   - notes files;
   - what has come up in the current conversation.
3. **Skip** anything already outsourced from this project: jobs in
   `~/outsource/*/LOCAL.md` whose `Source project:` is this project and
   whose status is not `dropped`.
4. **Filter.** Keep tasks that are generic by nature: trying out a setup,
   testing combinations of open-source tools, prototyping code, comparing
   tools, researching public documentation. Drop anything whose value
   depends on confidential context, and anything with high confidentiality
   risk.
5. **Report** in the conversation, ranked by usefulness, at most about ten.
   For each:
   - short title, and where it came from (`file:line` or "conversation");
   - the generic job as it would be sent, in one or two sentences;
   - why it can be outsourced, and what has to be genericised;
   - confidentiality risk: low or medium;
   - rough token saving: small, medium or large;
   - what stays local, e.g. applying the result to the project.
   Reporting that nothing suitable was found is a valid result.
6. Write nothing to disk. Tell the user to run `/outsource <task>` on the
   one they pick.
