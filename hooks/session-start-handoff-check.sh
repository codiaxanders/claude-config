#!/usr/bin/env bash
# Surfaces a project's HANDOFF.md (written by the /handoff command) at the
# start of any session, so a new session started in the same directory picks
# up prior context automatically. One-shot: the file is consumed and deleted
# right after being read, so it only ever applies to the next session.
set -uo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[[ -z "$CWD" ]] && exit 0

TARGET_DIR=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null) || TARGET_DIR="$CWD"
HANDOFF_FILE="$TARGET_DIR/HANDOFF.md"
[[ -f "$HANDOFF_FILE" ]] || exit 0

CONTENT=$(cat "$HANDOFF_FILE")

WARNINGS=""

TS=$(sed -n 's/^Timestamp: *//p' "$HANDOFF_FILE" | head -1)
if [[ -n "$TS" ]]; then
    TS_EPOCH=$(date -u -d "$TS" +%s 2>/dev/null)
    NOW_EPOCH=$(date -u +%s)
    if [[ -n "$TS_EPOCH" ]] && (( NOW_EPOCH - TS_EPOCH > 172800 )); then
        AGE_H=$(( (NOW_EPOCH - TS_EPOCH) / 3600 ))
        WARNINGS+=$'\n'"[Warning: this handoff is ${AGE_H}h old]"
    fi
fi

HANDOFF_BRANCH=$(sed -n 's/^Branch: *//p' "$HANDOFF_FILE" | head -1)
CURRENT_BRANCH=$(git -C "$TARGET_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -n "$HANDOFF_BRANCH" && -n "$CURRENT_BRANCH" && "$HANDOFF_BRANCH" != "$CURRENT_BRANCH" ]]; then
    WARNINGS+=$'\n'"[Warning: handoff was written on branch '$HANDOFF_BRANCH', current branch is '$CURRENT_BRANCH']"
fi

JSON_OUTPUT=$(CTX="$CONTENT$WARNINGS" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "Handoff notes found for this project (HANDOFF.md) and loaded below; the file has now been deleted. Before anything else, in your first reply tell the user in one short line that a handoff was loaded and give a one-line summary of its Status line (and mention any [Warning: ...] lines below if present). Then proceed normally.\n\n" + os.environ["CTX"]
    }
}))
') || exit 0

rm -f "$HANDOFF_FILE"
echo "$JSON_OUTPUT"
