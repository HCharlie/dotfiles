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

`gh` itself is installed later by `setup.sh` via the Brewfile for daily
PR/issue work. Bootstrap uses plain `git clone` because the repo is
public — no auth required. After setup, run `gh auth login` once when
you first need it.

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

## Other Useful Packages

### Desktop Applications
- **Rectangle** - window management
- **Clipy** - clipboard management
- **Hidden Bar** - menu bar organization
- **Stats** - system monitor in menu bar
- **KeyCastr** - keystroke visualizer
- **Visual Studio Code** - code editor
- **Zed** - modern code editor
- **Warp** - AI-powered terminal
- **Obsidian** - knowledge base
- **1Password** - password manager
- **Docker Desktop** - containers
- **UTM** - virtual machines
- **Ollama** - local LLM runtime
- **DevToys** - developer utilities
- **Kreya** - API client
- **RustDesk** - remote desktop
- **Hammerspoon** - macOS automation
- **KindaVim** - vim motions for macOS

### Command-Line Tools
- **bat** - better cat
- **eza** - modern ls
- **ripgrep** - fast search
- **fzf** - fuzzy finder
- **fd** - simple find
- **zoxide** - smart cd
- **atuin** - shell history
- **yazi** - file manager
- **tree** - directory viewer
- **neovim** - text editor
- **helix** - text editor
- **jj** - version control (Jujutsu)
- **lazygit** - git TUI
- **delta** - git diff viewer
- **btop** - process viewer
- **dust** - disk usage
- **duf** - disk usage
- **tldr** - simplified man pages
- **tmux** - terminal multiplexer
- **zellij** - terminal workspace
- **jq** - JSON processor
- **ffmpeg** - media processing
- **poppler** - PDF tools
- **resvg** - SVG renderer
- **sevenzip** - archiver
- **dive** - Docker image explorer
- **uv** - fast Python package manager
- **it-tools** - dev utilities


## Linux-Specific Tools

- **Hyprland** - dynamic tiling Wayland compositor
polybar
- **Rofi** - application launcher and dmenu replacement

### System Utilities
- **Waybar** - customizable Wayland bar
- **Dunst** - lightweight notification daemon
- **SwayNC** - notification center for Sway/Wayland
- **Hyprpaper** - wallpaper utility for Hyprland
- **wl-clipboard** - Wayland clipboard utilities
- **Grim** - screenshot utility for Wayland
- **Slurp** - select region for screenshots
- **witr** - why is this running

### what to do next (just ideas)
1. sshconfig
1. other tools with configs, like atuin, neovim, lazynvim, git, kindavim, aerospace, sketchybar,starship
1. linux tools
1. gh github cli
1. direnv for environment variable management