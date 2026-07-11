#!/usr/bin/env bash
# dumalog installer — curl -fsSL https://raw.githubusercontent.com/GoXLd/dumalog/main/install.sh | bash
set -euo pipefail

DUMALOG_HOME="${DUMALOG_HOME:-$HOME/.dumalog}"
BIN_DIR="$HOME/.local/bin"
REPO_URL="${DUMALOG_REPO:-https://github.com/GoXLd/dumalog.git}"

log()  { printf '\033[1;36m[dumalog]\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- 1. uv (needed for mempalace) ---------------------------------------
if ! have uv; then
  log "installing uv..."
  curl -fsSL https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- 2. mempalace --------------------------------------------------------
if ! have mempalace; then
  log "installing mempalace..."
  uv tool install mempalace
  export PATH="$HOME/.local/bin:$PATH"
else
  log "mempalace already installed: $(mempalace --version 2>/dev/null || echo ok)"
fi

# --- 3. hermes-agent (writing agent, OpenAI-compatible models) ----------
if ! have hermes; then
  log "installing hermes-agent (Nous Research)..."
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash || \
    log "WARNING: hermes install failed — dumalog will fall back to codex if present"
else
  log "hermes already installed"
fi

# --- 4. detect existing coding-agent sessions ----------------------------
CLAUDE_DIR="$HOME/.claude/projects"
CODEX_DIR="$HOME/.codex/sessions"
FOUND_SOURCES=()
if [ -d "$CLAUDE_DIR" ] && [ -n "$(ls -A "$CLAUDE_DIR" 2>/dev/null)" ]; then
  log "found Claude Code sessions: $CLAUDE_DIR"
  FOUND_SOURCES+=("$CLAUDE_DIR")
fi
if [ -d "$CODEX_DIR" ] && [ -n "$(ls -A "$CODEX_DIR" 2>/dev/null)" ]; then
  log "found Codex CLI sessions: $CODEX_DIR"
  FOUND_SOURCES+=("$CODEX_DIR")
fi
[ ${#FOUND_SOURCES[@]} -eq 0 ] && log "no Claude/Codex sessions found — mining skipped, run 'dumalog mine' later"

# --- 5. dumalog itself ----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/bin/dumalog" ]; then
  APP_DIR="$SCRIPT_DIR"          # running from a checkout
else
  APP_DIR="$DUMALOG_HOME/app"    # running via curl — clone
  if [ -d "$APP_DIR/.git" ]; then git -C "$APP_DIR" pull --ff-only; else
    mkdir -p "$DUMALOG_HOME"
    git clone --depth 1 "$REPO_URL" "$APP_DIR"
  fi
fi
mkdir -p "$BIN_DIR" "$DUMALOG_HOME"
ln -sf "$APP_DIR/bin/dumalog" "$BIN_DIR/dumalog"
chmod +x "$APP_DIR/bin/dumalog"
log "dumalog CLI installed -> $BIN_DIR/dumalog (app: $APP_DIR)"

# --- 6. first mine --------------------------------------------------------
for src in "${FOUND_SOURCES[@]}"; do
  log "mining $src into the palace (this may take a while)..."
  mempalace mine "$src" --mode convos || log "WARNING: mining $src failed — retry with 'dumalog mine'"
done

log "done. Next steps:"
log "  dumalog add-blog <git-url-or-path> [--posts-dir _posts] [--example <post-url-or-path>]"
log "  dumalog write \"topic of the post\""
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) log "NOTE: add $BIN_DIR to your PATH";; esac
