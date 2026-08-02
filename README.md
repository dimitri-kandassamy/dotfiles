# dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io).

## Fresh install

Order matters: the repo is cloned over **SSH** and 1Password serves the key, so 1Password
must be ready *before* chezmoi runs.

1. **Sign into your Apple ID** (System Settings) so the Mac App Store can install `mas` apps later.
2. **Install [1Password](https://1password.com/downloads/mac/)** → sign in → Settings →
   Developer → enable **SSH agent** and **CLI integration**. Make sure your SSH key exists as
   an *SSH Key* item and is registered on GitHub for both *Authentication* and *Signing*
   (see [Keys & commit signing](#keys--commit-signing-1password-ssh-agent)).
3. **Install [Homebrew](https://brew.sh)**, then chezmoi:
   ```bash
   brew install chezmoi
   chezmoi init --apply git@github.com:dimitri-kandassamy/dotfiles.git
   ```
   Homebrew's installer prints two `eval` lines to add `brew` to your `PATH` — run them, or
   just open a new terminal after installing (`~/.zprofile` handles it from then on).

   You'll be prompted for name, email, and `sshSigningKey`. chezmoi writes the config files
   first, then runs two scripts in order: `brew bundle` installs every package, and `~/.macos`
   applies the system preferences (expect a `sudo` password prompt, and Finder/Dock/Chrome
   restarting at the end).
4. Open a new shell — Starship, mise, zoxide, and fzf are live.

`10-brew.sh` re-runs whenever the `Brewfile` changes; `20-macos.sh` re-runs only when
`dot_macos` itself changes, so adding a package doesn't reapply every system default.

## What's included

### Shell
- **zsh** with [sheldon](https://sheldon.cli.rs) as plugin manager (replaces Oh My Zsh)
- [Starship](https://starship.rs) prompt (config at `~/.config/starship.toml`)
- Plugins: `zsh-autosuggestions`, `fast-syntax-highlighting`
- **iTerm2**, settings included (see [Terminal](#terminal)). Starship's symbols and
  `eza --icons` need a Nerd Font, so `font-meslo-lg-nerd-font` is in the `Brewfile`.
- `$EDITOR` / `git core.editor` are `code --wait`

### Version management
- **[mise](https://mise.jdx.dev)** — manages Node, Python, and Go versions via `.mise.toml` per project, replacing `nvm` and `pyenv`
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
`kubectl` · `k9s` — enough to talk to a remote cluster and look around. No local-cluster
tooling: `kind`, `helm`, `kubectx` and `stern` were dropped as unused.

### Cloud / infrastructure
`azure-cli` · `azure-functions-core-tools@4` · `terraform` (via `hashicorp` tap) · `dotnet`

### Containers
[colima](https://github.com/abiosoft/colima) instead of Docker Desktop — no licence and no
GUI daemon. The `docker` CLI, `docker-compose` and `docker-buildx` are separate formulae
(only Desktop bundled them); `10-brew.sh` links the plugins into `~/.docker/cli-plugins`.
Start the VM with `colima start`, or `brew services start colima` to have it start at login.

### Mobile / Android
Flutter (manual, see below) · Android SDK (manual, see below)

### Terminal
iTerm2 loads its settings from `~/.config/iterm2/` instead of its own prefs domain, so
profiles, fonts and keybindings are version-controlled. `dot_macos` flips the two
`defaults` keys that point it there. After changing something in iTerm2's UI, capture it:

```bash
chezmoi re-add ~/.config/iterm2/com.googlecode.iterm2.plist
```

Window positions and other volatile state (`NoSync*`, `NSWindow Frame*`, Sparkle keys)
are deliberately excluded from the tracked plist.

## Repository structure

```
dotfiles/
├── .chezmoi.toml.tmpl          # machine-level config (name, email, ssh signing key)
├── .chezmoiignore              # files not applied to $HOME
├── dot_zprofile                # → ~/.zprofile (Homebrew PATH, $EDITOR, 1Password socket)
├── dot_zshrc                   # → ~/.zshrc
├── dot_aliases                 # → ~/.aliases
├── dot_gitconfig.tmpl          # → ~/.gitconfig (SSH commit signing via 1Password)
├── dot_gitignore               # → ~/.gitignore (global excludes)
├── dot_macos                   # → ~/.macos (macOS system preferences script)
├── private_dot_ssh/
│   └── private_config          # → ~/.ssh/config (1Password agent for GUI apps too)
├── dot_config/
│   ├── starship.toml          # → ~/.config/starship.toml (prompt config)
│   ├── git/allowed_signers.tmpl # → ~/.config/git/allowed_signers (verify SSH signatures)
│   ├── sheldon/plugins.toml   # → ~/.config/sheldon/plugins.toml
│   ├── mise/config.toml       # → ~/.config/mise/config.toml
│   └── iterm2/com.googlecode.iterm2.plist # → ~/.config/iterm2/ (iTerm2 settings)
├── Brewfile                                       # Homebrew bundle manifest
├── run_onchange_after_10-brew.sh.tmpl             # brew bundle (re-runs on Brewfile change)
├── run_onchange_after_20-macos.sh.tmpl            # runs ~/.macos (re-runs on dot_macos change)
└── scripts/
    └── git-log-diary.sh                            # convert git log to a markdown diary
```

## Keys & commit signing (1Password SSH agent)

SSH keys are served by the [1Password SSH agent](https://developer.1password.com/docs/ssh/) —
they live in your vault and never touch disk. The same key is used for git/ssh
authentication **and** commit signing (git 2.34+ signs with SSH, no GPG needed).

On first `chezmoi init` you'll be prompted for:

- `sshSigningKey` — your SSH **public** key (e.g. `ssh-ed25519 AAAA…`). Empty disables
  commit signing. This is written to `~/.gitconfig` and `~/.config/git/allowed_signers`.

Setup (one-time, in the 1Password desktop app):

1. Settings → Developer → enable **SSH agent** and **CLI integration**.
2. Store your SSH key as an **SSH Key** item (import the existing one if needed).
3. Open the item → **Configure Commit Signing**, and copy the public key into `sshSigningKey`.
4. Register the key on GitHub for **both** "Authentication" and "Signing".

Wiring, once applied:

- `~/.ssh/config` sets `IdentityAgent` to the 1Password socket. This is what makes the agent
  work for GUI apps and non-interactive shells — VS Code's built-in git, LaunchAgents, cron —
  none of which read `~/.zshrc`.
- `~/.zprofile` also exports `SSH_AUTH_SOCK`, for tools that read it directly (`ssh-add -l`).
- `~/.gitconfig` points `gpg.ssh.program` at 1Password's `op-ssh-sign` binary.

## Manual steps (after the install)

1Password, the Mac App Store, and Homebrew are covered in [Fresh install](#fresh-install).
What remains:

- **Flutter SDK** — download from [flutter.dev](https://flutter.dev) and place at `~/DevTools/flutter/`.
- **Android SDK** — `android-studio` is in the `Brewfile`; open it once to download the SDK to `~/Library/Android/sdk`.
- **eTax.zug** — Swiss tax software, not on Homebrew; reinstall by hand when needed.
- **VS Code** — sign in and enable Settings Sync to restore extensions and settings.
- **iTerm2** — settings are restored automatically, but iTerm2 only re-reads them on
  launch. If it was already running during the install, quit and reopen it once.

## Day-to-day workflow

```bash
chezmoi update          # pull latest from the remote and apply
chezmoi apply           # re-apply local source to $HOME (idempotent)
chezmoi diff            # preview pending changes before applying
chezmoi cd              # drop into the source dir ($HOME/.local/share/chezmoi)
chezmoi re-add ~/.zshrc # capture local edits back into the source
chezmoi doctor          # diagnose a broken setup
```

After editing files inside the source dir, commit and push from there:

```bash
chezmoi cd
git add . && git commit -m "…" && git push
```

## Adding a new machine variable

Edit `.chezmoi.toml.tmpl` to add a `promptStringOnce` line and a `[data]` entry, then reference it as `{{ .variableName }}` in any `*.tmpl` file. Existing machines won't re-prompt unless you delete the value from `~/.config/chezmoi/chezmoi.toml`.

## Thanks

- [GitHub does dotfiles](https://dotfiles.github.io/) for resources and inspiration
- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) for the comprehensive macOS preferences
- [Dries Vint](https://github.com/driesvints/dotfiles), [Zach Holman](https://github.com/holman/dotfiles) and [Jessie Frazelle](https://github.com/jessfraz/dotfiles) for sharing their dotfiles

## License

This project is licensed under the [MIT License](./LICENSE).
