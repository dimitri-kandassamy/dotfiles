# dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io).

## Fresh install

**Prerequisite:** [Homebrew](https://brew.sh)

```bash
brew install chezmoi
chezmoi init --apply git@github.com:dimitri-kandassamy/dotfiles.git
```

This clones the repo, applies config files to `$HOME`, and runs the install script which installs all Homebrew packages and applies macOS system preferences. The script re-runs automatically whenever the `Brewfile` changes.

## What's included

### Shell
- **zsh** with [sheldon](https://sheldon.cli.rs) as plugin manager (replaces Oh My Zsh)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt with instant prompt
- Plugins: `zsh-autosuggestions`, `fast-syntax-highlighting`

### Version management
- **[mise](https://mise.jdx.dev)** — manages Node, Python, Go, and Terraform versions via `.mise.toml` per project, replacing `nvm` and `pyenv`
- **[uv](https://docs.astral.sh/uv)** — Python package and virtualenv management

### Modern CLI
| Tool | Replaces | Purpose |
|------|----------|---------|
| `eza` | `ls` | Directory listings with git status and icons |
| `bat` | `cat` | Syntax-highlighted file output |
| `fd` | `find` | Fast, gitignore-aware file search |
| `ripgrep` | `grep` | Fast recursive code search |
| `fzf` | — | Fuzzy finder (Ctrl+R history, Ctrl+T file picker) |
| `zoxide` | `cd` | Smart directory jumping with frecency |
| `delta` | git diff | Syntax-highlighted diffs with side-by-side support |
| `lazygit` | git CLI | Terminal UI for staging, rebasing, and branch management |
| `yq` | — | YAML processor (pairs with `jq`) |

### Kubernetes
`k9s` · `kubectx` · `kubens` · `stern` · `helm` · `kind`

### Cloud / infrastructure
`azure-cli` · `azure-functions-core-tools@4` · `terraform` (version-managed via mise)

### Mobile / Android
`apktool` · `jadx` · Flutter (manual, see below) · Android SDK (manual, see below)

## Repository structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # machine-level config (name, email)
├── .chezmoiignore              # files not applied to $HOME
├── dot_zshrc                   # → ~/.zshrc
├── dot_aliases                 # → ~/.aliases
├── dot_gitconfig               # → ~/.gitconfig
├── dot_macos                   # → ~/.macos (macOS system preferences script)
├── dot_config/
│   ├── sheldon/plugins.toml   # → ~/.config/sheldon/plugins.toml
│   └── mise/config.toml       # → ~/.config/mise/config.toml
├── Brewfile                    # Homebrew bundle manifest
├── run_onchange_install.sh.tmpl # installs brew packages + applies macOS prefs (re-runs on Brewfile change)
└── scripts/
    └── git-log-diary.sh        # convert git log to a markdown diary
```

## Manual steps

A few things still require manual setup after `chezmoi apply`:

- **Flutter SDK** — download from [flutter.dev](https://flutter.dev) and place at `~/DevTools/flutter/`
- **Android SDK** — install via Android Studio; SDK path is expected at `~/Library/Android/sdk`
- **GPG key** — import your private key: `gpg --import private.key`
- **SSH keys** — generate or restore: `ssh-keygen -t ed25519 -C "your@email.com"`
- **1Password** — sign in to unlock secrets referenced in templates

## Adding a new machine config

Edit `.chezmoi.toml.tmpl` to add machine-specific variables and use `{{ .variableName }}` in any `*.tmpl` dotfile.

## Thanks

- [GitHub does dotfiles](https://dotfiles.github.io/) for resources and inspiration
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) for the comprehensive macOS preferences
- [Dries Vint](https://github.com/driesvints/dotfiles), [Zach Holman](https://github.com/holman/dotfiles) and [Jessie Frazelle](https://github.com/jessfraz/dotfiles) for sharing their dotfiles

## License

This project is licensed under the [MIT License](./LICENSE).
