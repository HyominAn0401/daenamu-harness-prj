#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_PATH="$ROOT_DIR/.git/hooks/pre-commit"

cd "$ROOT_DIR"

if [[ ! -d .git/hooks ]]; then
  echo "Cannot find .git/hooks. Run this inside a Git working tree."
  exit 1
fi

cat > "$HOOK_PATH" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

exec scripts/commit-hook.sh
HOOK

chmod +x "$HOOK_PATH"

echo "Installed DAENAMU README drift pre-commit hook:"
echo "$HOOK_PATH"
