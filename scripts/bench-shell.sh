#!/usr/bin/env bash
# Measures zsh startup time. Run it before and after touching ~/.zshrc or
# plugins.toml — the point of the deferred loading and the compinit cache is a
# number, not a claim.
#
#     ./scripts/bench-shell.sh
#
# `zsh -i -c exit` starts an interactive shell and exits immediately, so it pays
# the full ~/.zshrc cost. Anything under ~100ms is imperceptible; if it climbs
# past ~250ms, something is loading eagerly that shouldn't be.
#
# Recorded on the Intel MacBook Pro (macOS 26.5.2, x86_64), 2026-08-16:
#
#   ~460ms   legacy Oh My Zsh + Powerlevel10k, measured on the live machine
#    ~60ms   this config, measured in a sandbox with NO tools installed
#
# The second number is not a result — it is a floor. With sheldon, starship,
# mise, zoxide and fzf absent, every integration in ~/.zshrc short-circuits on
# its `command -v` guard, so it measures an almost empty file. It is recorded
# only to show the config itself adds nothing measurable.
#
# THE REAL NUMBER IS STILL UNMEASURED. Take it on the rebuilt machine once
# `brew bundle` has run, and replace this line with it. Expect it to land well
# above 60ms and, if the deferral is working, below ~150ms.

set -euo pipefail

if ! command -v hyperfine &>/dev/null; then
  echo "hyperfine not installed: brew install hyperfine" >&2
  exit 1
fi

echo "Interactive zsh startup:"
hyperfine --warmup 3 --shell=none 'zsh -i -c exit'

echo
echo "To find what is slow, profile with zprof:"
echo "  1. add 'zmodload zsh/zprof' as the first line of ~/.zshrc"
echo "  2. add 'zprof' as the last line"
echo "  3. open a new shell, read the table, then remove both lines"
