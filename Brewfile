# taps
tap "azure/functions"
tap "hashicorp/tap"

# version management — replaces nvm + pyenv
brew "mise"
brew "uv"

# shell
brew "sheldon"
brew "starship"

# azure
brew "azure-cli"
brew "azure/functions/azure-functions-core-tools@4"

# cloud / infra
brew "hashicorp/tap/terraform"
# kubectl itself — previously only present because Docker Desktop bundled it,
# which every other tool here silently depended on
brew "kubernetes-cli"
brew "helm"
brew "kind"
brew "k9s"
brew "kubectx"
brew "stern"

# containers — colima replaces Docker Desktop (no licence, no GUI daemon).
# `colima start` boots the VM; the docker CLI and its plugins are separate
# formulae because only the Desktop app used to bundle them.
brew "colima"
brew "docker"
brew "docker-compose"
brew "docker-buildx"

# .NET (C# dev + Azure Functions)
brew "dotnet"

# core dev tools
brew "ffmpeg"
brew "gh"
brew "git"
brew "hugo"
brew "jq"
brew "yq"
brew "pandoc"
brew "pnpm"
brew "scc"
brew "tree"

# modern cli
brew "bat"
brew "eza"
brew "fd"
brew "fzf"
brew "ripgrep"
brew "zoxide"

# git
brew "git-delta"
brew "lazygit"

# misc dev
brew "ocrmypdf"
brew "typst"

# mac app store cli
brew "mas"

# fonts — Starship's prompt symbols and `eza --icons` are Nerd Font glyphs, and
# the iTerm2 profile pins MesloLGSNerdFont-Regular. Previously this font arrived
# as a side effect of the Powerlevel10k wizard, which is gone.
cask "font-meslo-lg-nerd-font"

# apps
cask "1password"
# 1password cli (chezmoi secret integration + SSH agent) — cask, not a formula
cask "1password-cli"
cask "affinity"
cask "android-studio"
cask "audacity"
cask "brave-browser"
cask "calibre"
cask "claude"
cask "claude-code"
cask "discord"
cask "figma"
cask "firefox"
cask "google-chrome"
cask "iterm2"
cask "microsoft-teams"
cask "ngrok"
cask "notion"
cask "obs"
cask "ollama-app"
cask "slack"
cask "spotify"
cask "visual-studio-code"
cask "vlc"
cask "zoom"

# mac app store apps (IDs from `mas list`)
mas "Xcode", id: 497799835
mas "Numbers", id: 409203825
mas "iMovie", id: 408981434
# dropped: Evernote (406056744) — no longer used
