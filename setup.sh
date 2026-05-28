#!/usr/bin/env bash
# setup.sh — onboard a new machine to use this Claude Code config repo.
#
# Run once after cloning:
#   git clone git@github.com:codiaxanders/claude-config ~/github/codiaxanders/claude-config
#   ~/github/codiaxanders/claude-config/setup.sh
#
# Safe to re-run — existing files are backed up, not overwritten.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# ── Helpers ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "  ${GREEN}✓${RESET} $*"; }
warn()    { echo -e "  ${YELLOW}!${RESET} $*"; }
error()   { echo -e "  ${RED}✗${RESET} $*"; }
section() { echo -e "\n${BOLD}$*${RESET}"; }

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        local name
        name=$(basename "$target")
        cp -r "$target" "$BACKUP_DIR/$name"
        warn "Backed up existing $(basename "$target") to $BACKUP_DIR/"
    fi
}

make_symlink() {
    local src="$1"
    local dst="$2"
    backup_if_exists "$dst"
    ln -sfn "$src" "$dst"
    info "Linked $dst → $src"
}

# ── Preflight ─────────────────────────────────────────────────────────────────

section "Claude Code config setup"
echo "  Repo: $REPO_DIR"
echo "  Target: $CLAUDE_DIR"

if ! command -v claude &>/dev/null; then
    warn "claude not found in PATH — install it first:"
    warn "  npm install -g @anthropic-ai/claude-code"
    warn "Continuing with symlink setup anyway..."
fi

# ── Create ~/.claude if needed ────────────────────────────────────────────────

section "Preparing ~/.claude"
mkdir -p "$CLAUDE_DIR"
info "~/.claude exists"

# ── Symlink managed files ─────────────────────────────────────────────────────

section "Creating symlinks"

make_symlink "$REPO_DIR/CLAUDE.md"      "$CLAUDE_DIR/CLAUDE.md"
make_symlink "$REPO_DIR/settings.json"  "$CLAUDE_DIR/settings.json"
make_symlink "$REPO_DIR/hooks"          "$CLAUDE_DIR/hooks"
make_symlink "$REPO_DIR/agents"         "$CLAUDE_DIR/agents"
make_symlink "$REPO_DIR/templates"      "$CLAUDE_DIR/templates"

# ── Ensure hook is executable ─────────────────────────────────────────────────

section "Hook permissions"
chmod +x "$REPO_DIR/hooks/pre-commit-check.sh"
info "hooks/pre-commit-check.sh is executable"

# ── Verify credentials are NOT in the repo ───────────────────────────────────

section "Credential safety check"
CRED_FILE="$REPO_DIR/.credentials.json"
if [[ -f "$CRED_FILE" ]]; then
    error ".credentials.json found in repo — this must never be committed!"
    error "Remove it immediately: rm $CRED_FILE"
    exit 1
else
    info ".credentials.json not in repo (correct)"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

section "Done"
echo ""
echo -e "  ${BOLD}Next step:${RESET} authenticate with your Anthropic account:"
echo -e "  ${BOLD}  claude auth${RESET}"
echo ""
echo -e "  To switch accounts later:"
echo -e "    rm ~/.claude/.credentials.json && claude auth"
echo ""
