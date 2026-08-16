#!/usr/bin/env bash
# Points this repo's git at .githooks/. Run once after cloning:
#
#     ./scripts/install-hooks.sh
#
# core.hooksPath is per-clone local config, so it can't be committed and has to
# be set on each machine.

set -euo pipefail

cd "$(dirname "$0")/.."

git config core.hooksPath .githooks
chmod +x .githooks/*

echo "Hooks installed. Test with: git commit --allow-empty -m test"
