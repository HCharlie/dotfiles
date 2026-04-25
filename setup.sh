#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting dotfiles setup..."

echo ""
echo "============================================================================"
echo "🔍 Checking prerequisites..."
echo "============================================================================"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install Homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Homebrew is installed"
echo ""

echo "============================================================================"
echo "📂 Setting up Stow and deploying dotfiles..."
echo "============================================================================"

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
echo ""

echo "============================================================================"
echo "🐚 Setting up Oh My Zsh..."
echo "============================================================================"

# Install Oh My Zsh (following XDG spec)
ZSH_DIR="$ZDOTDIR/ohmyzsh"
if [ ! -d "$ZSH_DIR" ]; then
    echo "🐚 Installing Oh My Zsh to $ZSH_DIR..."
    # RUNZSH=no prevents running zsh after installation
    # KEEP_ZSHRC=yes keeps existing .zshrc without prompting
    # ZSH controls the installation directory
    ZSH="$ZSH_DIR" RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed"
else
    echo "✅ Oh My Zsh already installed"
fi

# Install zsh-autosuggestions (following XDG spec)
ZSH_CUSTOM="$ZSH_DIR/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions to $ZSH_CUSTOM/plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions installed"
else
    echo "✅ zsh-autosuggestions already installed"
fi

echo "✅ Oh My Zsh setup complete!"
echo ""

echo "============================================================================"
echo "📦 Installing Ghostty..."
echo "============================================================================"
if ! command -v ghostty &> /dev/null; then
    brew install ghostty
    echo "✅ Ghostty installed"
else
    echo "✅ Ghostty already installed"
fi

echo "✅ Ghostty setup complete!"
echo ""

echo "============================================================================"
echo "📜 Installing Atuin..."
echo "============================================================================"
if ! command -v atuin &> /dev/null; then
    brew install atuin
    echo "✅ Atuin installed"
else
    echo "✅ Atuin already installed"
fi

echo "✅ Atuin setup complete!"
echo "ℹ️  Run 'atuin login -u <user>' or 'atuin register' to enable sync (per-machine)."
echo ""

echo "============================================================================"
echo "🖥️  Setting up tmux and plugins..."
echo "============================================================================"

# Install tmux
if ! command -v tmux &> /dev/null; then
    echo "📦 Installing tmux..."
    brew install tmux
    echo "✅ tmux installed"
else
    echo "✅ tmux already installed"
fi

# Verify tmux installation
if command -v tmux &> /dev/null; then
    TMUX_VERSION=$(tmux -V)
    echo "✅ tmux verification passed: $TMUX_VERSION"
else
    echo "❌ tmux installation failed or not in PATH"
    exit 1
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

# Verify TPM installation
if [ -f "$TPM_DIR/tpm" ] && [ -f "$TPM_DIR/scripts/install_plugins.sh" ]; then
    echo "✅ TPM verification passed"
else
    echo "❌ TPM installation incomplete - missing required files"
    exit 1
fi

# Install plugins using TPM
echo "🔄 Installing tmux plugins..."

# TPM needs a running tmux server to read plugin declarations from tmux.conf
# The install_plugins.sh script uses 'tmux show-option' commands internally
echo "📝 Starting temporary tmux session to load configuration..."

# Kill any existing tmux server to ensure clean state
tmux kill-server 2>/dev/null || true

# Start a detached tmux session
# When tmux starts, it automatically:
#   1. Reads ~/.config/tmux/tmux.conf
#   2. Parses 'set -g @plugin' declarations
#   3. Executes 'run tpm' at the end (which loads already-installed plugins)
tmux new-session -d -s setup_session 2>/dev/null || {
    echo "⚠️  Warning: Could not create tmux session, but continuing..."
}

# Give tmux a moment to initialize and read the config
sleep 1

# Now run TPM's install script to download and install the declared plugins
# This script queries the running tmux server for the @plugin declarations
if [ -f "$TPM_DIR/scripts/install_plugins.sh" ]; then
    echo "📦 Downloading and installing plugins..."
    "$TPM_DIR/scripts/install_plugins.sh" || {
        echo "⚠️  Warning: TPM plugin installation encountered issues"
    }
    echo "✅ Tmux plugins installed"
else
    echo "⚠️  Warning: TPM install script not found"
fi

# Verify plugin installation
PLUGIN_COUNT=$(find "$HOME/.local/share/tmux/plugins" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [ "$PLUGIN_COUNT" -gt 1 ]; then
    echo "✅ Plugin verification passed: $PLUGIN_COUNT plugins installed"
else
    echo "⚠️  Warning: Expected multiple plugins but found $PLUGIN_COUNT"
fi

# Clean up the setup session
tmux kill-session -t setup_session 2>/dev/null || true

echo "✅ Tmux setup complete!"
echo ""

echo "============================================================================"
echo "📝 Setting up Neovim config..."
echo "============================================================================"

NVIM_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_DIR" ]; then
    echo "📦 Cloning Neovim config..."
    git clone https://github.com/HCharlie/kickstart.nvim "$NVIM_DIR"
    echo "✅ Neovim config cloned"
else
    echo "✅ Neovim config already exists"
fi

echo ""
echo "============================================================================"
echo "🎉 Setup complete!"
echo "============================================================================"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal for environment variables to take effect"
