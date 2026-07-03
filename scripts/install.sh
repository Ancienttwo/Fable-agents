#!/usr/bin/env bash
# Installs the user's standard model-routing setup. Idempotent; never
# overwrites a differing file (reports [conflict] and exits 3 instead).
#   1. .claude/agents/{fast-worker,deep-reasoner}.md into the target project
#   2. "## Model Routing Hierarchy" section into the global CLAUDE.md
#   3. codex plugin (openai/codex-plugin-cc) + readiness check
#   4. headless smoke test of both agents
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../assets"
PROJECT_DIR="$(pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKIP_PLUGIN=0
SKIP_SMOKE=0
CONFLICT=0

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    --skip-plugin) SKIP_PLUGIN=1; shift ;;
    --skip-smoke) SKIP_SMOKE=1; shift ;;
    *) echo "usage: install.sh [--project <dir>] [--skip-plugin] [--skip-smoke]" >&2; exit 2 ;;
  esac
done

install_agent() {
  local name="$1"
  local src="$ASSETS_DIR/$name.md"
  local dst="$PROJECT_DIR/.claude/agents/$name.md"
  mkdir -p "$PROJECT_DIR/.claude/agents"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "[new] agent $name installed at $dst"
  elif cmp -s "$src" "$dst"; then
    echo "[ok] agent $name up to date"
  else
    echo "[conflict] agent $name differs from bundled version — review: diff '$dst' '$src'"
    CONFLICT=1
  fi
}

install_global_section() {
  local md="$CLAUDE_HOME/CLAUDE.md"
  local marker='## Model Routing Hierarchy'
  mkdir -p "$CLAUDE_HOME"
  if [ -f "$md" ] && grep -qF "$marker" "$md"; then
    echo "[ok] global CLAUDE.md already contains '$marker'"
    return
  fi
  if [ -s "$md" ]; then printf '\n' >> "$md"; fi
  cat "$ASSETS_DIR/model-routing-hierarchy.md" >> "$md"
  echo "[new] appended '$marker' to $md"
}

ensure_plugin() {
  if ! command -v claude >/dev/null 2>&1; then
    echo "[warn] claude CLI not found — install Claude Code, then re-run"
    return
  fi
  if claude plugin list 2>/dev/null | grep -q 'codex@openai-codex'; then
    echo "[ok] codex plugin already installed"
  else
    claude plugin marketplace add openai/codex-plugin-cc >/dev/null 2>&1 || true
    if claude plugin install codex@openai-codex >/dev/null 2>&1; then
      echo "[new] codex plugin installed (user scope)"
    else
      echo "[warn] codex plugin install failed — run: claude plugin marketplace add openai/codex-plugin-cc && claude plugin install codex@openai-codex"
      return
    fi
  fi
  check_codex_ready
}

check_codex_ready() {
  local companion
  companion="$(ls "$CLAUDE_HOME"/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs 2>/dev/null | tail -1 || true)"
  if [ -z "$companion" ] || ! command -v node >/dev/null 2>&1; then
    echo "[warn] codex readiness not checked (companion script or node missing) — run /codex:setup in a session"
    return
  fi
  if CLAUDE_PLUGIN_ROOT="$(dirname "$(dirname "$companion")")" node "$companion" setup --json 2>/dev/null | grep -q '"ready": true'; then
    echo "[ok] codex runtime ready (CLI + auth verified)"
  else
    echo "[warn] codex runtime not ready — needs 'npm install -g @openai/codex' and/or 'codex login', then /codex:setup"
  fi
}

smoke_agent() {
  local name="$1" out
  out="$(cd "$PROJECT_DIR" && claude -p --agent "$name" 'Reply with exactly one word: ready' 2>&1 | tail -1 || true)"
  case "$out" in
    *eady*) echo "[ok] smoke $name: replied '$out'" ;;
    *) echo "[warn] smoke $name failed, last output: $out" ;;
  esac
}

echo "== setup-model-routing: project=$PROJECT_DIR global=$CLAUDE_HOME =="
install_agent fast-worker
install_agent deep-reasoner
install_global_section
if [ "$SKIP_PLUGIN" -eq 0 ]; then ensure_plugin; else echo "[skip] plugin step"; fi
if [ "$SKIP_SMOKE" -eq 0 ]; then smoke_agent fast-worker; smoke_agent deep-reasoner; else echo "[skip] smoke tests"; fi

if [ "$CONFLICT" -eq 1 ]; then
  echo "== done with conflicts — resolve [conflict] lines above =="
  exit 3
fi
echo "== done =="
