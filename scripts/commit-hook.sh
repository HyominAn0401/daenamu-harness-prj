#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "[DAENAMU Agent Harness] README drift check started"

scripts/run-agent.sh

echo
echo "[DAENAMU Agent Harness] Ground truth extracted."
echo "Reports:"
echo "- agent/reports/latest-ground-truth.md"
echo "- agent/reports/latest-ground-truth.json"
echo "Codex should compare these reports with README.md and patch README.md when drift is confirmed."
