#!/usr/bin/env bash
# Updates local-claude-configuration to the latest version.
# Safe to run multiple times.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Updating local-claude-configuration..."

cd "$REPO_DIR"

BEFORE=$(git rev-parse --short HEAD)
git pull
AFTER=$(git rev-parse --short HEAD)

if [[ "$BEFORE" == "$AFTER" ]]; then
  echo "Already up to date ($AFTER)."
else
  echo ""
  echo "Updated: $BEFORE → $AFTER"
  echo ""
  git log --oneline "${BEFORE}..${AFTER}"
  echo ""
  echo "Re-running install to apply any new files..."
  bash "$REPO_DIR/install.sh"
fi

echo ""
echo "Reload your shell to activate any changes: source ~/.zshrc"
