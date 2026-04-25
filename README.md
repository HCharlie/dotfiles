# Dotfiles

Personal dotfiles managed with GNU Stow.

## Quick Setup

1. Install Homebrew. macOS ships `git` via Xcode Command Line Tools,
   which Homebrew's installer prompts to install on first run if missing
   — no separate `brew install git` needed.
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Clone and run setup. `DOTFILES_DIR` can be any path; the example
   below mirrors GitHub's namespace under `~/src` so multiple cloned
   repos stay organized side by side.
```bash
DOTFILES_DIR="$HOME/src/github.com/HCharlie/dotfiles"
mkdir -p "$(dirname "$DOTFILES_DIR")"
git clone https://github.com/HCharlie/dotfiles "$DOTFILES_DIR"
cd "$DOTFILES_DIR"
./setup.sh
```

3. Restart your terminal

## Design Notes

- [zsh layout](zsh/README.md) — kernel rc vs. `~/.zshrc` sandbox, why this split, migration tips.

## Managing Tools (Brewfile)

`Brewfile` declares the core tools this dotfiles repo wants on every
machine — the things you'd be unhappy without. `setup.sh` applies it
via `brew bundle`.

Anything else you `brew install` ad-hoc is intentionally NOT tracked.
The Brewfile is curated, not exhaustive.

```bash
# Apply (what setup.sh does):
brew bundle --file=Brewfile

# Try a new tool without committing to it:
brew install some-cli                    # ad-hoc, untracked

# Decide later — promote to Brewfile (edit + commit) or uninstall.

# Drift audit (what's installed but not in Brewfile)?
brew bundle cleanup --file=Brewfile      # list only

# Regenerate from current state (rare — defeats curation):
brew bundle dump --force --describe --file=/tmp/Brewfile.dump
```

`brew bundle cleanup` will list every untracked install as drift —
that's expected here; the curated Brewfile is intentionally narrow.
Treat the cleanup output as a "review what you've accumulated"
prompt, not an instruction to uninstall.

## Post-Install

### Atuin (shell history sync)

History is local-only by default. To sync across machines:

```bash
# First machine — create account
atuin register -u <username> -e <email>

# Other machines — log in with the same account
atuin login -u <username>

# Import existing shell history (run once per machine)
atuin import auto

# Push local history up
atuin sync
```

Notes:
- Sync server defaults to `https://api.atuin.sh`. Self-host via `sync_address` in `atuin/config.toml` if needed.
- Encryption key lives at `~/.local/share/atuin/key` — back it up; without it, synced history cannot be decrypted on a new machine.
- After login on a new machine, run `atuin key` on an existing machine and `atuin key set <key>` on the new one to share the key.

## What's Installed

The full curated list of CLI tools and casks lives in [`Brewfile`](Brewfile).
`setup.sh` applies it via `brew bundle` on a fresh machine.