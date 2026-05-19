#!/usr/bin/env bash
# Bootstrap a new machine using chezmoi.
# Prerequisites: Homebrew (https://brew.sh)
set -euo pipefail

if ! command -v brew &>/dev/null; then
  echo "Homebrew is required. Install it first: https://brew.sh"
  exit 1
fi

brew install chezmoi
chezmoi init --apply git@github.com:dimitri-kandassamy/dotfiles.git
