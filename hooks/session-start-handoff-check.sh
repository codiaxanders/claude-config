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
rm -f "$HANDOFF_FILE"

CTX="$CONTENT" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "Handoff notes found for this project (HANDOFF.md):\n\n" + os.environ["CTX"]
    }
}))
'
