# Dotfiles

Personal dotfiles managed with GNU Stow for easy deployment and version control.

## Prerequisites

- GNU Stow must be installed on your system 
- XDG env variables must be set in the ~/.zshenv

```.zshenv
# XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Create the necessary directories using mkdir -p
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_STATE_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$ZDOTDIR"
mkdir -p "$XDG_DATA_HOME/zsh" # for HISTFILE "$XDG_DATA_HOME/zsh/history
```

### Installation

**Quick Setup (Recommended):**
```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
stow .
```

### Following steps
1. Install homebrew, install stow
1. Ensure the ~/.zshenv file
1. clone the dotfiles, and execute the stow command
1. install tpm for tmux to XDG_DATA_HOME(.local/share/tmux/...)
1. install ohmyzsh + zshautocompletion


