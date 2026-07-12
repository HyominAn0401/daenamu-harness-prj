#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/agent/reports"

cd "$ROOT_DIR"
mkdir -p "$REPORT_DIR"

git diff -- . ':!agent/reports/latest-git-diff.patch' > "$REPORT_DIR/latest-git-diff.patch"
git diff --cached -- . ':!agent/reports/latest-git-diff.patch' > "$REPORT_DIR/latest-git-diff-staged.patch"

python3 agent/orchestrator/extract_ground_truth.py "$@"

echo
echo "Git diff report:"
echo "- agent/reports/latest-git-diff.patch"
echo "- agent/reports/latest-git-diff-staged.patch"
