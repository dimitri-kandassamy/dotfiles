# Enable Powerlevel10k instant prompt — must stay near the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Sheldon plugin manager (replaces Oh My Zsh)
command -v sheldon &>/dev/null && eval "$(sheldon source)"

# mise — polyglot version manager (Node, Python, Go, Terraform …)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# fzf shell integration (Ctrl+R, Ctrl+T, Alt+C)
command -v fzf &>/dev/null && source <(fzf --zsh)

# zoxide — smart cd with frecency tracking
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Aliases
source "$HOME/.aliases"

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Go — user-installed binaries (go install …)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Flutter SDK
export PATH="$PATH:$HOME/DevTools/flutter/bin"

# Dart pub cache (mason CLI, etc.)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# Dart CLI completion
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && source "$HOME/.dart-cli-completion/zsh-config.zsh"

# Terraform shell completion
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C "$(which terraform 2>/dev/null || true)" terraform
