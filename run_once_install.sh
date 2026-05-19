#!/usr/bin/env bash
# Runs once on the first `chezmoi apply`. Idempotent — safe to re-run manually.
set -euo pipefail

DOTFILES_DIR="$(chezmoi source-path)"

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install all packages
brew bundle --file="$DOTFILES_DIR/Brewfile"

# Apply macOS system preferences
# shellcheck source=dot_macos
source "$DOTFILES_DIR/dot_macos"
