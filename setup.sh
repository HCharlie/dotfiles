#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting dotfiles setup..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Check if Stow is installed
if ! command -v stow &> /dev/null; then
    echo "📦 Installing Stow..."
    brew install stow
else
    echo "✅ Stow already installed"
fi

# Deploy dotfiles using Stow
echo "📂 Deploying dotfiles with Stow..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Stow home files (like .zshenv)
stow -t ~ --dotfiles home
echo "✅ Home dotfiles deployed to ~"

# Source .zshenv to create XDG directories immediately
# This ensures they exist before the next stow command
echo "📁 Setting up environment and creating directories..."
source "$HOME/.zshenv"
echo "✅ Environment configured"

# Stow configs to ~/.config
stow .
echo "✅ Configs deployed to ~/.config"

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    # RUNZSH=no prevents running zsh after installation
    # KEEP_ZSHRC=yes keeps existing .zshrc without prompting
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed"
else
    echo "✅ Oh My Zsh already installed"
fi

# Install zsh-autosuggestions
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions installed"
else
    echo "✅ zsh-autosuggestions already installed"
fi

# Install tmux and ghostty
echo "📦 Installing tmux and ghostty..."
if ! command -v tmux &> /dev/null; then
    brew install tmux
    echo "✅ tmux installed"
else
    echo "✅ tmux already installed"
fi

if ! command -v ghostty &> /dev/null; then
    brew install ghostty
    echo "✅ ghostty installed"
else
    echo "✅ ghostty already installed"
fi

# Install Tmux Plugin Manager
TPM_DIR="$HOME/.local/share/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "🔌 Installing Tmux Plugin Manager..."
    mkdir -p "$HOME/.local/share/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "✅ TPM installed"
else
    echo "✅ TPM already installed"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal for environment variables to take effect"
echo "   2. In tmux, press 'prefix + r' to reload config"
echo "   3. In tmux, press 'prefix + I' to install plugins via TPM"
