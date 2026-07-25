#!/usr/bin/env bash
# Reports git status for the "bah", "reference_docs", "notes_closed" and
# "claude_collaboration" repos if they exist on this machine. Read-only: never
# pulls, commits, or pushes - it only surfaces state so Claude can flag it and
# ask the user what to do.
set -uo pipefail

check_repo() {
    local dir="$1" label="$2"
    [[ -d "$dir/.git" ]] || return 0

    timeout 5 git -C "$dir" fetch --quiet 2>/dev/null || true

    local branch ahead behind counts uncommitted
    branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || branch="?"

    if git -C "$dir" rev-parse '@{u}' >/dev/null 2>&1; then
        counts=$(git -C "$dir" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
        behind=$(echo "$counts" | cut -f1)
        ahead=$(echo "$counts" | cut -f2)
    else
        behind="no-upstream"; ahead="no-upstream"
    fi

    uncommitted=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    echo "### $label ($dir)"
    echo "branch: $branch | ahead: $ahead | behind: $behind | uncommitted files: $uncommitted"
    if [[ "$uncommitted" -gt 0 ]]; then
        git -C "$dir" status --porcelain 2>/dev/null | head -20 | sed 's/^/  /'
    fi
    echo
}

output=$( {
    check_repo "$HOME/bah" "bah"
    check_repo "$HOME/reference_docs" "reference_docs"
    check_repo "$HOME/notes/notes_closed" "notes_closed"
    check_repo "$HOME/notes/claude_collaboration" "claude_collaboration"
} )

if [[ -z "$output" ]]; then
    exit 0
fi

CTX="$output" python3 -c '
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "Git repo status check (bah/reference_docs/notes_closed/claude_collaboration):\n" + os.environ["CTX"]
    }
}))
'
