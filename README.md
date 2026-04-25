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