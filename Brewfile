# Brewfile — personal machine (MacBook Pro, Intel / x86_64).
#
# Deliberately excluded: anything that arrives on this machine by some other
# route. `brew bundle` fails outright when it finds an app it did not install,
# and that aborts the rest of run_onchange_after_10-brew.sh before it reaches
# the plugin fetch and `mise install`. If you install something by hand, take it
# out of here rather than letting two update mechanisms fight over one bundle.
#
# Intel notes (verified 2026-08-16 on macOS 26.5.2 / x86_64):
#   - Every cask below reports `arch: any` — none are Apple-Silicon-only.
#   - Every formula below resolves to an x86_64 bottle. Homebrew's newest Intel
#     bottle tag is `sonoma` and it is used as-is on Tahoe, so nothing here
#     compiles from source. Re-check with `brew fetch <formula>` if an install
#     ever starts building instead of downloading.
#   - Tahoe is the last macOS release for Intel, so expect this to change
#     eventually. It is not a problem today.

# taps
tap "hashicorp/tap"

# ---------------------------------------------------------------- version mgmt
brew "mise"          # Node / Python / Go versions, per project via .mise.toml
brew "uv"            # Python packages, venvs and tools — replaces pip/pipx/poetry

# The tool that installs everything else. Bootstrapped by hand in README step 2,
# but listed here so `brew bundle` owns its upgrades from then on — otherwise
# chezmoi is the one binary on the machine that never gets updated.
brew "chezmoi"

# ----------------------------------------------------------------------- shell
brew "sheldon"       # zsh plugin manager (Rust, lockfile-backed)
brew "starship"      # prompt

# ------------------------------------------------------------------ python dev
brew "ruff"          # linter + formatter — replaces black, flake8, isort

# -------------------------------------------------------------- javascript dev
brew "pnpm"          # content-addressed store; node itself comes from mise

# ------------------------------------------------------------- cloud / infra
brew "hashicorp/tap/terraform"
# kubectl itself — previously only present because Docker Desktop bundled it,
# which every other tool here silently depended on
brew "kubernetes-cli"
brew "k9s"
brew "helm"          # chart tooling; kubectl alone can't install anything real
brew "kind"          # throwaway clusters in the colima VM, no cloud round-trip
brew "azure-cli"     # `az` — the Azure DevOps reporting scripts shell out to it

# ------------------------------------------------------------------ containers
# colima replaces Docker Desktop (no licence, no GUI daemon). `colima start`
# boots the VM; the docker CLI and its plugins are separate formulae because
# only the Desktop app used to bundle them.
brew "colima"
brew "docker"
brew "docker-compose"
brew "docker-buildx"

# ------------------------------------------------------------------- .NET / C#
brew "dotnet"

# -------------------------------------------------------------------- core dev
brew "gh"
brew "git"
brew "git-delta"     # syntax-highlighted diffs, wired into git via ~/.gitconfig
brew "lazygit"
brew "hugo"
brew "jq"
brew "yq"
brew "pandoc"
brew "scc"
brew "tree"

# ------------------------------------------------------------------ modern cli
brew "bat"           # cat
brew "eza"           # ls
brew "fd"            # find
brew "ripgrep"       # grep
brew "fzf"           # fuzzy finder — Ctrl+R, Ctrl+T, and fzf-tab completions
brew "zoxide"        # cd with frecency
brew "hyperfine"     # benchmarking; used by scripts/bench-shell.sh
brew "watchexec"     # run a command when files change

# -------------------------------------------------------------------- security
# Scans staged changes for secrets before they reach a commit. The repo's own
# pre-commit hook calls this; see scripts/install-hooks.sh.
brew "gitleaks"

# ------------------------------------------------------------------ shell lint
# This repo is seven bash scripts, three of which run unattended on a fresh
# machine with `set -euo pipefail` and no one watching. Lint them.
brew "shellcheck"

# --------------------------------------------------------- mac app store cli
brew "mas"

# ----------------------------------------------------------------------- fonts
# Ghostty, VS Code and the Starship prompt all reference this family; the prompt
# symbols and `eza --icons` are Nerd Font glyphs. Meslo stays because the
# iTerm2 profile still pins MesloLGSNerdFont-Regular.
cask "font-jetbrains-mono-nerd-font"
cask "font-meslo-lg-nerd-font"

# ------------------------------------------------------------------------ apps
cask "1password"
# 1password cli (chezmoi secret integration + SSH agent) — cask, not a formula
cask "1password-cli"
cask "ghostty"                  # daily terminal — plain-text config
cask "iterm2"                   # fallback terminal
cask "visual-studio-code"
cask "audacity"
cask "calibre"
cask "claude"
cask "claude-code"
cask "figma"
cask "google-chrome"
cask "notion"
cask "ollama-app"               # Intel + no discrete GPU: CPU-only inference
cask "spotify"
cask "vlc"

# ------------------------------------------------------- mac app store apps
# IDs from `mas list`.
mas "Xcode", id: 497799835
mas "Numbers", id: 409203825
mas "iMovie", id: 408981434
# dropped: Evernote (406056744) — no longer used
