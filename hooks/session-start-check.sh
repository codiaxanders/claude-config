#!/usr/bin/env bash
# Keeps ~/.claude in sync with the claude-config repo at every session start:
# pulls fast-forward updates, re-runs setup.sh, and auto-syncs the two
# plugin-manifest files (their lastUpdated timestamp churns on every plugin
# check, so committing them by hand doesn't scale). Anything else that's
# uncommitted or unpushed is only reported, never touched.
set -uo pipefail

REPO_DIR="$HOME/github/codiaxanders/claude-config"
notes=()
warnings=()

emit() {
    local summary="claude-config: "
    if [[ ${#notes[@]} -eq 0 ]]; then
        summary+="up to date"
    else
        summary+=$(IFS=', '; echo "${notes[*]}")
    fi
    if [[ ${#warnings[@]} -gt 0 ]]; then
        summary+=" | needs attention: "$(IFS='; '; echo "${warnings[*]}")
    fi
    MSG="$summary" python3 -c '
import json, os
print(json.dumps({"systemMessage": os.environ["MSG"]}))
'
}

if [[ ! -d "$REPO_DIR/.git" ]]; then
    warnings+=("repo not found at $REPO_DIR")
    emit
    exit 0
fi

sync_state() {
    local local_rev upstream_rev base_rev
    local_rev=$(git -C "$REPO_DIR" rev-parse @ 2>/dev/null)
    upstream_rev=$(git -C "$REPO_DIR" rev-parse '@{u}' 2>/dev/null)
    if [[ -z "$upstream_rev" ]]; then
        echo "no-upstream"; return
    fi
    if [[ "$local_rev" == "$upstream_rev" ]]; then
        echo "synced"; return
    fi
    base_rev=$(git -C "$REPO_DIR" merge-base @ '@{u}' 2>/dev/null)
    if [[ "$local_rev" == "$base_rev" ]]; then
        echo "behind"
    elif [[ "$upstream_rev" == "$base_rev" ]]; then
        echo "ahead"
    else
        echo "diverged"
    fi
}

if git -C "$REPO_DIR" fetch --quiet 2>/dev/null; then
    case "$(sync_state)" in
        behind)
            if git -C "$REPO_DIR" pull --ff-only --quiet 2>/dev/null; then
                notes+=("pulled latest")
            else
                warnings+=("fast-forward pull failed")
            fi
            ;;
        diverged)
            warnings+=("local and upstream have diverged — resolve manually")
            ;;
    esac
else
    warnings+=("could not reach upstream (offline?)")
fi

if bash "$REPO_DIR/setup.sh" >/tmp/claude-config-setup.log 2>&1; then
    :
else
    warnings+=("setup.sh failed — see /tmp/claude-config-setup.log")
fi

plugin_files=("plugins/installed_plugins.json" "plugins/known_marketplaces.json")
other_dirty=()
plugin_dirty=()
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    f="${line:3}"
    match=false
    for pf in "${plugin_files[@]}"; do
        [[ "$f" == "$pf" ]] && match=true
    done
    if $match; then
        plugin_dirty+=("$f")
    else
        other_dirty+=("$f")
    fi
done < <(git -C "$REPO_DIR" status --porcelain 2>/dev/null)

if [[ ${#plugin_dirty[@]} -gt 0 ]]; then
    if git -C "$REPO_DIR" add "${plugin_dirty[@]}" 2>/dev/null \
       && git -C "$REPO_DIR" commit --quiet -m "Sync plugin state" 2>/dev/null \
       && git -C "$REPO_DIR" push --quiet 2>/dev/null; then
        notes+=("synced plugin state")
    else
        warnings+=("plugin state changed but auto commit/push failed")
    fi
fi

if [[ ${#other_dirty[@]} -gt 0 ]]; then
    warnings+=("uncommitted changes: ${other_dirty[*]}")
fi

case "$(sync_state)" in
    ahead)
        warnings+=("unpushed commits in claude-config — push when ready")
        ;;
    diverged)
        warnings+=("claude-config diverged from upstream")
        ;;
esac

emit
