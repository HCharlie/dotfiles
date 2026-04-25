# Dotfiles

Personal dotfiles managed with GNU Stow.

## Quick Setup

1. Install Homebrew, Git, and GitHub CLI:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git gh
gh auth login
```

2. Clone and run setup:
```bash
# Pick any path you like. Example uses ~/src/github.com/<owner>/<repo>:
DOTFILES_DIR="$HOME/src/github.com/HCharlie/dotfiles"
mkdir -p "$(dirname "$DOTFILES_DIR")"
gh repo clone HCharlie/dotfiles "$DOTFILES_DIR"
cd "$DOTFILES_DIR"
./setup.sh
```

3. Restart your terminal

## Design Notes

- [zsh layout](zsh/README.md) — kernel rc vs. `~/.zshrc` sandbox, why this split, migration tips.

## Managing Tools (Brewfile, tiered)

Tool installation is split across three tiers so the core stays stable
while experiments and work-specific tools have looser homes.

| File | Purpose | Tracked in git? |
|---|---|---|
| `Brewfile` | Core, certain tools. Stable, rarely changes. | ✅ |
| `Brewfile.experimental` | Trial / evaluation tools. Expected to churn. Promote to `Brewfile` once proven, remove if abandoned. | ✅ |
| `Brewfile.work` | Company-specific tools, private taps, sensitive items. Lives only on the machines that need it. | ❌ (gitignored) |
| `Brewfile.work.example` | Template showing how to structure `Brewfile.work`. | ✅ |

`setup.sh` applies all three in order. Tiers 2 and 3 are guarded with
`[[ -f ... ]]` so missing files are simply skipped.

Day-to-day workflow:

```bash
# Apply the whole stack (what setup.sh does).
brew bundle --file=Brewfile
[[ -f Brewfile.experimental ]] && brew bundle --file=Brewfile.experimental
[[ -f Brewfile.work         ]] && brew bundle --file=Brewfile.work

# Trying out a new tool — add to Brewfile.experimental, apply.
echo 'brew "tldr"' >> Brewfile.experimental
brew bundle --file=Brewfile.experimental

# After a few weeks, decide: promote to Brewfile, or remove.

# Drift audit (anything installed but NOT covered by ANY of the three?):
brew bundle cleanup --file=Brewfile
brew bundle cleanup --file=Brewfile.experimental
brew bundle cleanup --file=Brewfile.work    # if present

# Regenerate from current state (rarely; defeats curation):
brew bundle dump --force --describe --file=Brewfile.dump
```

### Setting up a work machine

```bash
cp Brewfile.work.example Brewfile.work
$EDITOR Brewfile.work        # add company taps + tools
./setup.sh
```

`Brewfile.work` is gitignored, so company taps and private SSH-only
taps stay off GitHub.

### Why tiers

- **Stability isolation.** A flaky experimental tool can't break a
  fresh-machine bootstrap — it lives in tier 2.
- **Audit clarity.** `cat Brewfile` always shows what you actually
  rely on. `cat Brewfile.experimental` shows what you're testing.
- **Privacy.** Work-only taps (e.g. `git@github.com:company/...`)
  never enter the public repo.
- **Promotion path.** `experimental` → `Brewfile` is just a one-line
  move once a tool earns its keep.

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