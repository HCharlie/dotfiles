# Dotfiles

Personal dotfiles managed with GNU Stow.

## Installation

### 1. Install Homebrew & Stow

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
```

### 2. Configure XDG Environment

Add to `~/.zshenv`:

```zsh
# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Create directories
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$ZDOTDIR"
mkdir -p "$XDG_DATA_HOME/zsh"

# Local overrides
touch ~/.zshrc.local
```

Restart your terminal for the environment variables to take effect.

### 3. Deploy Dotfiles

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
stow .
```

### 4. Install Shell Plugins

```bash
# Oh My Zsh (answer 'n' when asked to rename .zshrc)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### 5. Install Tmux & Ghostty

```bash
brew install tmux ghostty
```

### 6. Install Tmux Plugin Manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
```

Then in tmux: `prefix + r` to reload the tmux config, `prefix + I` to install plugins via tpm.
