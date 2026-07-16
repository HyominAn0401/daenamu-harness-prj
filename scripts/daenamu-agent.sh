#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_BIN="${CODEX_BIN:-codex}"
PROMPT_FILE="$ROOT_DIR/agent/orchestrator/daenamu_agent_prompt.md"

cd "$ROOT_DIR"

if [[ $# -gt 0 ]]; then
  USER_REQUEST="$*"
else
  echo "DAENAMU agent request:"
  read -r USER_REQUEST
fi

if [[ -z "${USER_REQUEST// }" ]]; then
  echo "No request provided." >&2
  exit 2
fi

if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
  echo "Codex CLI not found: $CODEX_BIN" >&2
  echo "Install Codex CLI or set CODEX_BIN to the executable path." >&2
  exit 127
fi

echo "[DAENAMU Agent] Observing repository ground truth"
scripts/run-agent.sh

COMBINED_PROMPT="$(
  cat "$PROMPT_FILE"
  printf '\n## User request\n\n'
  printf '%s\n' "$USER_REQUEST"
)"

echo
echo "[DAENAMU Agent] Running LLM agent"
echo "- runner: $CODEX_BIN"
echo "- request: $USER_REQUEST"
echo

"$CODEX_BIN" exec --full-auto "$COMBINED_PROMPT"

echo
echo "[DAENAMU Agent] Finished"
echo "Review changes with:"
echo "git diff -- README.md agent/reports"
