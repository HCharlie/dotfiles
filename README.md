# Dotfiles

Personal dotfiles managed with GNU Stow.

## Installation

### 1. Install Homebrew & Stow & Git

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow git
```

### 2. Deploy Dotfiles

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
stow .                         # configs to ~/.config
stow -t ~ --dotfiles home      # .zshenv to ~
```

Restart your terminal for the environment variables to take effect.

### 3. Install Shell Plugins

```bash
# Oh My Zsh (answer 'n' when asked to rename .zshrc)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### 4. Install Tmux & Ghostty

```bash
brew install tmux ghostty
```

### 5. Install Tmux Plugin Manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
```

Then in tmux: `prefix + r` to reload the tmux config, `prefix + I` to install plugins via tpm.
