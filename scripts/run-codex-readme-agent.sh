#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_BIN="${CODEX_BIN:-codex}"
PROMPT_FILE="$ROOT_DIR/agent/orchestrator/codex_prompt.md"

cd "$ROOT_DIR"

if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
  echo "Codex CLI를 찾지 못했습니다: $CODEX_BIN" >&2
  echo "CODEX_BIN 환경변수로 Codex 실행 파일을 지정하거나 Codex CLI를 설치하세요." >&2
  exit 127
fi

scripts/run-agent.sh

echo
echo "[DAENAMU Agent Harness] Codex README drift agent started"
echo "- prompt: agent/orchestrator/codex_prompt.md"
echo "- target: README.md"
echo

"$CODEX_BIN" exec --full-auto "$(cat "$PROMPT_FILE")"

echo
echo "[DAENAMU Agent Harness] Codex README drift agent finished"
echo "변경 확인:"
echo "git diff -- README.md"
