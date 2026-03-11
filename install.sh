#!/usr/bin/env bash
# Installs worktree-open into your shell.
# Safe to run multiple times (idempotent).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
MAIN_ZSH="$REPO_DIR/zsh/worktree-open.zsh"

echo "Installing worktree-open from: $REPO_DIR"

# Option A: oh-my-zsh custom directory (auto-loaded, no .zshrc edit needed)
if [[ -d "$HOME/.oh-my-zsh/custom" ]]; then
  LINK="$HOME/.oh-my-zsh/custom/worktree-open.zsh"
  if [[ -e "$LINK" || -L "$LINK" ]]; then
    echo "Already installed at: $LINK"
  else
    ln -s "$MAIN_ZSH" "$LINK"
    echo "Linked: $LINK -> $MAIN_ZSH"
  fi
  echo ""
  echo "Reload your shell to activate: source ~/.zshrc"
  echo "To update later, run:          bash $REPO_DIR/update.sh"
  exit 0
fi

# Option B: append source line to .zshrc
SOURCE_LINE="source \"$MAIN_ZSH\""
ZSHRC="$HOME/.zshrc"

if grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
  echo "Already installed in: $ZSHRC"
else
  {
    echo ""
    echo "# worktree-open (local-claude-configuration)"
    echo "$SOURCE_LINE"
  } >> "$ZSHRC"
  echo "Added to: $ZSHRC"
fi

echo ""
echo "Reload your shell to activate: source ~/.zshrc"
echo "To update later, run:          bash $REPO_DIR/update.sh"
