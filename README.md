# dotfiles

macOS configuration managed with [chezmoi](https://www.chezmoi.io).

**Target:** MacBook Pro (Intel / x86_64), macOS 26 Tahoe. Homebrew prefix `/usr/local`.

---

## Overview

| Area       | Tooling                                                                                              |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| Shell      | zsh, [sheldon](https://sheldon.cli.rs) plugins, [starship](https://starship.rs) prompt               |
| Languages  | [mise](https://mise.jdx.dev) (node, python, go), [uv](https://docs.astral.sh/uv/) (python packaging) |
| Terminal   | Ghostty (primary), iTerm2 (fallback)                                                                 |
| Editor     | VS Code — settings, keybindings and extensions tracked                                               |
| Containers | colima + docker CLI                                                                                  |
| Cloud      | terraform, kubectl, k9s                                                                              |
| Secrets    | 1Password SSH agent for auth and commit signing                                                      |
| CLI        | bat, eza, fd, ripgrep, fzf, zoxide, jq, yq, delta, lazygit, gh                                       |

---

## Prerequisites

Complete all of these **before** starting the installation.

### 1. Back up the old machine

Confirm you can restore anything not in a git remote — SSH keys are in 1Password,
but local-only work is not.

### 2. Install macOS and complete Setup Assistant

Create your user account and connect to a network. Skip Migration Assistant if
you want a genuinely clean install.

### 3. Sign in to the App Store

Open the App Store app and sign in. The `Brewfile` will install Xcode, Numbers and
iMovie via `mas`, which cannot sign in on your behalf.

---

## Installation

### Step 1 — Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/usr/local/bin/brew shellenv)"
```

The installer also installs the Xcode Command Line Tools if missing. Run the
`eval` now — the next step depends on it. From the next shell onward,
`~/.zprofile` handles it.

### Step 2 — Install chezmoi and apply

```bash
brew install chezmoi
chezmoi init --apply https://github.com/dimitri-kandassamy/dotfiles.git
```

You will be prompted for four values:

| Prompt          | Answer                                                    |
| --------------- | --------------------------------------------------------- |
| Name            | Git author name                                           |
| Email           | Git author email                                          |
| GitHub username | Your GitHub handle                                        |
| SSH signing key | Your existing public key, `ssh-ed25519 AAAA…` — see below |

Copy the GitHub signing key from [github.com/settings/keys](https://github.com/settings/keys).

### Step 3 — Wait for the install scripts

Three scripts run automatically, in order:

| Script      | Actions                                                                      | Re-runs when                    |
| ----------- | ---------------------------------------------------------------------------- | ------------------------------- |
| `10-brew`   | `brew bundle`, links docker CLI plugins, fetches zsh plugins, `mise install` | `Brewfile` changes              |
| `20-vscode` | installs VS Code extensions                                                  | `vscode/extensions.txt` changes |
| `30-macos`  | runs `~/.macos` — prompts for sudo, restarts Dock and Finder                 | `dot_macos` changes             |

Allow 30–60 minutes.

### Step 4 — Configure 1Password

1. Open 1Password and sign in.
2. **Settings → Developer** → enable **SSH agent** and **CLI integration**.
3. Confirm your key exists as an **SSH Key** item (not a note or password), and
   that it is the same key you pasted in Step 2.
4. On [github.com/settings/keys](https://github.com/settings/keys), confirm the
   key is registered as an _Authentication key_ and as a
   _Signing key_.

Verify the two paths:

```bash
ls ~/Library/Group\ Containers/ | grep -i 1password
ls /Applications/1Password.app/Contents/MacOS/op-ssh-sign
```

Open a new terminal, then confirm the agent is reachable:

```bash
ssh -T git@github.com
```

### Step 5 — Switch the source repository to SSH

The clone in Step 2 used HTTPS. Now that the agent works, move it to SSH:

```bash
git -C "$(chezmoi source-path)" remote set-url origin git@github.com:dimitri-kandassamy/dotfiles.git
```

### Step 6 — Install the commit hooks

Installs the `gitleaks` credential scan. `core.hooksPath` is per-clone local
configuration and cannot be committed, so this is required on every machine.

```bash
chezmoi cd
./scripts/install-hooks.sh
exit
```

### Step 7 — Restart

Some macOS defaults require a logout or restart to take effect.

---

## Verification

Open a new terminal — the starship prompt should appear with no errors — then run
each block.

**Git identity and SSH agent.**

```bash
git config user.email
git config user.name
ssh -T git@github.com
ssh-add -l
```

**Commit signing.** Runs in a scratch repository and cleans up after itself.

```bash
(
  d=$(mktemp -d) && cd "$d" && git init -q .
  git commit --allow-empty -qm "signing test"
  git log --show-signature -1
  rm -rf "$d"
)
```

Expect `Good "git" signature`.

**Toolchain and packages.**

```bash
mise ls
brew bundle check --file="$(chezmoi source-path)/Brewfile"
```

**Shell startup time.** Record this figure; it is the baseline for future changes.

```bash
"$(chezmoi source-path)/scripts/bench-shell.sh"
```

---

## Manual steps

Not automated, by design.

| Task            | Notes                                                                         |
| --------------- | ----------------------------------------------------------------------------- |
| **Colima**      | `colima start` to boot the container VM. Not started automatically            |
| **Flutter SDK** | Install to `~/DevTools/flutter`. `~/.zshrc` adds it to `PATH` only if present |
| **Android SDK** | Install via Android Studio. Detected at `~/Library/Android/sdk`               |
| **Ghostty**     | Launch once and set as the default terminal                                   |
| **iTerm2**      | Reads settings from `~/.config/iterm2/`. Quit and relaunch to pick them up    |
| **App logins**  | Chrome, Spotify, Notion, Figma, Claude                                        |
| **Xcode**       | Launch once to accept the licence and install components                      |

---

## Day-to-day

```bash
chezmoi edit ~/.zshrc       # edit the source, not the target
chezmoi diff                # preview pending changes
chezmoi apply               # apply them
chezmoi re-add ~/.aliases   # pull a hand-edited target back into the source
chezmoi cd                  # subshell in the source directory
chezmoi update              # git pull, then apply
```

Editing a target file directly works, but `chezmoi apply` will overwrite it. Use
`chezmoi edit`, or `chezmoi re-add` afterwards.

**Adding a package:** edit the `Brewfile`, then `chezmoi apply`. The script hash
changes and `10-brew` re-runs.

**Updating zsh plugins:** plugins are pinned to commits in
`dot_config/sheldon/plugins.toml`. Resolve a new revision with
`git ls-remote https://github.com/<owner>/<repo> HEAD` and update the `rev`.

**Capturing iTerm2 settings:** quit iTerm2 first — it rewrites preferences on
exit — then `chezmoi re-add ~/.config/iterm2/com.googlecode.iterm2.plist`.

**Changing a prompted value:** `chezmoi init --prompt` re-asks every prompt and
rewrites `~/.config/chezmoi/chezmoi.toml`. Plain `chezmoi init` will not change
an answer that is already recorded.

---

## Machine-local overrides

Untracked files for anything machine-specific or private. All are optional and
safe when absent.

| File                            | Purpose                                             |
| ------------------------------- | --------------------------------------------------- |
| `~/.zshenv.local`               | environment variables, tokens                       |
| `~/.zshrc.local`                | interactive aliases and functions                   |
| `~/.ssh/config.local`           | per-host ssh settings                               |
| `~/.config/git/local.gitconfig` | alternate identities, url rewrites, private remotes |

The two include directives are positioned for opposite precedence rules and must
stay where they are: ssh takes the **first** value it sees, so its `Include` is at
the top of `~/.ssh/config`; git takes the **last**, so its `[include]` is at the
bottom of `~/.gitconfig`.

---

## Repository layout

```
.
├── .chezmoi.toml.tmpl                  # prompts → ~/.config/chezmoi/chezmoi.toml
├── .chezmoiignore                      # source-only files, never applied
├── .editorconfig
├── .githooks/pre-commit                # gitleaks credential scan
├── Brewfile                            # packages, casks, App Store apps
├── dot_zshenv                          # → ~/.zshenv    (XDG paths, every shell)
├── dot_zprofile                        # → ~/.zprofile  (login shells)
├── dot_zshrc                           # → ~/.zshrc     (interactive shells)
├── dot_aliases                         # → ~/.aliases
├── dot_gitconfig.tmpl                  # → ~/.gitconfig
├── dot_gitignore                       # → ~/.gitignore (global)
├── dot_macos                           # → ~/.macos     (system defaults)
├── dot_config/
│   ├── ghostty/config
│   ├── git/allowed_signers.tmpl
│   ├── iterm2/com.googlecode.iterm2.plist
│   ├── mise/config.toml
│   ├── sheldon/plugins.toml
│   └── starship.toml
├── private_dot_ssh/private_config      # → ~/.ssh/config
├── Library/Application Support/Code/User/
│   ├── settings.json
│   └── keybindings.json
├── vscode/extensions.txt
├── scripts/
│   ├── bench-shell.sh                  # zsh startup benchmark
│   ├── install-hooks.sh
│   └── git-log-diary.sh
├── run_onchange_after_10-brew.sh.tmpl
├── run_onchange_after_20-vscode.sh.tmpl
└── run_onchange_after_30-macos.sh.tmpl
```

---

## Troubleshooting

**`brew bundle` fails immediately.**
An application in the `Brewfile` is already installed by another route. Remove
that line, or uninstall the application and let Homebrew manage it.

**VS Code extensions were skipped.**
The `code` CLI was not on `PATH`. Open VS Code once, then `chezmoi apply --force`.

**`git commit` fails with `failed to write commit object`.**
A signing key is configured but the 1Password signing helper is unreachable.
Confirm 1Password is running and Step 4 is complete.

**Commits succeed but are unsigned.**
The signing key was left empty in Step 2. Re-run `chezmoi init --prompt`, then
`chezmoi apply`. The `--prompt` flag is required: plain `chezmoi init` will not
change an answer that is already recorded, even an empty one.

**`ssh -T git@github.com` fails.**
Confirm the 1Password SSH agent is enabled and the socket path in
`~/.ssh/config` matches what Step 4 verified.

**Commits are blocked by the pre-commit hook.**
`gitleaks` is missing or found a potential secret. The hook fails closed by
design: `brew install gitleaks`, or move the value to a machine-local file.

**Shell startup feels slow.**
Run `scripts/bench-shell.sh`. Above ~250 ms, profile by adding
`zmodload zsh/zprof` as the first line of `~/.zshrc` and `zprof` as the last.

**Adding a new configuration variable.**
Add a `promptStringOnce` line to `.chezmoi.toml.tmpl`, reference it as
`{{ .yourVar }}` in any `.tmpl` file, then run `chezmoi init --prompt`.

---

## Credits

macOS defaults originally derived from
[mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles).

## License

MIT — see [LICENSE](LICENSE).
