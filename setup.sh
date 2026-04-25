#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting dotfiles setup..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "============================================================================"
echo "🔍 Checking prerequisites..."
echo "============================================================================"

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "✅ Homebrew is installed"
echo ""

echo "============================================================================"
echo "📂 Bootstrapping Stow + deploying dotfiles..."
echo "============================================================================"

# Bootstrap: install Stow up-front so we can deploy configs BEFORE the
# full Brewfile bundle runs. With symlinks already in place, any tool
# that creates a default config on first run will see an existing
# (curated) file and skip writing defaults.
if ! command -v stow &> /dev/null; then
    echo "📦 Installing Stow (bootstrap)..."
    brew install stow
else
    echo "✅ Stow already installed"
fi

cd "$SCRIPT_DIR"

# Stow home files (like .zshenv)
stow -t ~ --dotfiles home
echo "✅ Home dotfiles deployed to ~"

# Source .zshenv so XDG paths exist before downstream tools look for them.
echo "📁 Setting up environment and creating directories..."
source "$HOME/.zshenv"
echo "✅ Environment configured"

# Stow configs to ~/.config (symlinks now in place before tool first-runs)
stow .
echo "✅ Configs deployed to ~/.config"
echo ""

echo "============================================================================"
echo "📦 Installing tools and apps from Brewfile..."
echo "============================================================================"

brew bundle --file="$SCRIPT_DIR/Brewfile"
echo "✅ Brewfile applied"
echo ""

echo "============================================================================"
echo "🐚 Setting up Oh My Zsh..."
echo "============================================================================"

# Install Oh My Zsh under ZDOTDIR so it follows the XDG Base Dir spec
# (ZDOTDIR is set by ~/.zshenv to $XDG_CONFIG_HOME/zsh).
ZSH_DIR="$ZDOTDIR/ohmyzsh"
if [ ! -d "$ZSH_DIR" ]; then
    echo "🐚 Installing Oh My Zsh to $ZSH_DIR..."
    # ZSH       — install destination (instead of the default ~/.oh-my-zsh).
    # RUNZSH=no — don't drop into a zsh subshell after install.
    # KEEP_ZSHRC=yes — leave any existing .zshrc untouched (we manage it via stow).
    ZSH="$ZSH_DIR" RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed"
else
    echo "✅ Oh My Zsh already installed"
fi

# Install zsh-autosuggestions into the same XDG-compliant tree.
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
echo "🖥️  Setting up tmux plugins..."
echo "============================================================================"

# tmux itself is installed by Brewfile; here we set up TPM + plugins.
TMUX_VERSION=$(tmux -V)
echo "✅ tmux available: $TMUX_VERSION"

TPM_DIR="$HOME/.local/share/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "🔌 Installing Tmux Plugin Manager..."
    mkdir -p "$HOME/.local/share/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "✅ TPM installed"
else
    echo "✅ TPM already installed"
fi

if [ -f "$TPM_DIR/tpm" ] && [ -f "$TPM_DIR/scripts/install_plugins.sh" ]; then
    echo "✅ TPM verification passed"
else
    echo "❌ TPM installation incomplete - missing required files"
    exit 1
fi

echo "🔄 Installing tmux plugins..."
echo "📝 Starting temporary tmux session to load configuration..."

# Kill any existing tmux server to ensure clean state.
tmux kill-server 2>/dev/null || true

# Start a detached tmux session so TPM can read its config. When tmux
# starts it automatically:
#   1. reads ~/.config/tmux/tmux.conf
#   2. parses `set -g @plugin '...'` declarations
#   3. executes `run tpm` at the end (loads any already-installed plugins)
tmux new-session -d -s setup_session 2>/dev/null || {
    echo "⚠️  Warning: Could not create tmux session, but continuing..."
}

# Give tmux a moment to initialize and finish reading the config before
# install_plugins.sh starts querying it.
sleep 1

# Now run TPM's install script to download and install the declared
# plugins. The script queries the running tmux server (started above)
# via `tmux show-option` to learn the @plugin declarations.
if [ -f "$TPM_DIR/scripts/install_plugins.sh" ]; then
    echo "📦 Downloading and installing plugins..."
    "$TPM_DIR/scripts/install_plugins.sh" || {
        echo "⚠️  Warning: TPM plugin installation encountered issues"
    }
    echo "✅ Tmux plugins installed"
else
    echo "⚠️  Warning: TPM install script not found"
fi

# Verify plugin installation — TPM itself counts as one entry, so a
# successful run leaves multiple directories under tmux/plugins.
PLUGIN_COUNT=$(find "$HOME/.local/share/tmux/plugins" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [ "$PLUGIN_COUNT" -gt 1 ]; then
    echo "✅ Plugin verification passed: $PLUGIN_COUNT plugins installed"
else
    echo "⚠️  Warning: Expected multiple plugins but found $PLUGIN_COUNT"
fi

# Clean up the temporary tmux session used to bootstrap TPM.
tmux kill-session -t setup_session 2>/dev/null || true

echo "✅ Tmux setup complete!"
echo ""

echo "============================================================================"
echo "📝 Setting up Neovim config..."
echo "============================================================================"

# Neovim binary installed via Brewfile; here we just clone the config repo.
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
echo "📜 Atuin (post-install hint)"
echo "============================================================================"
echo "ℹ️  To enable cross-machine history sync, see README.md → Post-Install → Atuin."
echo "   Quick: 'atuin register' (first machine) or 'atuin login -u <user>' + 'atuin import auto'."
echo ""

echo "============================================================================"
echo "🎉 Setup complete!"
echo "============================================================================"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal so the new shell stack (Oh My Zsh,"
echo "      atuin init, aliases, autosuggestions) loads."
echo "   2. Run 'atuin register' or 'atuin login -u <user>' if you want"
echo "      cross-machine history sync (see README.md)."
echo "   3. Open Neovim once to let kickstart.nvim install its plugins."
