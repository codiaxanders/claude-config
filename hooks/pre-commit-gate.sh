#!/usr/bin/env bash
# PreToolUse gate for the Bash matcher: reads the tool-call JSON sent on
# stdin, and if it's a `git commit` invocation, hands off to
# pre-commit-check.sh with the actual command in GIT_COMMIT_CMD.
#
# Tool-call input arrives as JSON on stdin
# ({"tool_name": "...", "tool_input": {"command": "..."}, ...}), not via an
# env var — a prior version of this gate read a nonexistent env var and so
# never actually ran the check.
set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -qE '^git commit'; then
    GIT_COMMIT_CMD="$CMD" exec "$(dirname "${BASH_SOURCE[0]}")/pre-commit-check.sh"
else
    exit 0
fi
