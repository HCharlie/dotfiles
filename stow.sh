#!/usr/bin/env bash

# Dotfiles stow management script
# This script automatically runs stow for each directory in the dotfiles repo

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    print_error "GNU Stow is not installed. Please install it first:"
    echo "  macOS: brew install stow"
    echo "  Linux: sudo apt-get install stow (or equivalent)"
    exit 1
fi

# Function to stow a package
stow_package() {
    local package="$1"
    local action="${2:-stow}"

    if [ "$action" = "stow" ]; then
        print_info "Stowing $package..."
        if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" "$package" 2>&1; then
            print_success "Stowed $package"
        else
            print_error "Failed to stow $package"
            return 1
        fi
    elif [ "$action" = "restow" ]; then
        print_info "Restowing $package..."
        if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" -R "$package" 2>&1; then
            print_success "Restowed $package"
        else
            print_error "Failed to restow $package"
            return 1
        fi
    elif [ "$action" = "unstow" ]; then
        print_info "Unstowing $package..."
        if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" -D "$package" 2>&1; then
            print_success "Unstowed $package"
        else
            print_error "Failed to unstow $package"
            return 1
        fi
    fi
}

# Get all directories (excluding .git and other hidden directories)
get_packages() {
    find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name '.' \
        ! -name '.git*' \
        ! -name '.*' \
        -exec basename {} \; | sort
}

# Main script logic
ACTION="${1:-stow}"
SPECIFIC_PACKAGE="$2"

case "$ACTION" in
    stow|install)
        if [ -n "$SPECIFIC_PACKAGE" ]; then
            # Stow specific package
            if [ -d "$DOTFILES_DIR/$SPECIFIC_PACKAGE" ]; then
                stow_package "$SPECIFIC_PACKAGE" "stow"
            else
                print_error "Package '$SPECIFIC_PACKAGE' not found"
                exit 1
            fi
        else
            # Stow all packages
            echo "Stowing all packages..."
            while IFS= read -r package; do
                stow_package "$package" "stow"
            done < <(get_packages)
            print_success "All packages stowed successfully!"
        fi
        ;;

    restow|update)
        if [ -n "$SPECIFIC_PACKAGE" ]; then
            # Restow specific package
            if [ -d "$DOTFILES_DIR/$SPECIFIC_PACKAGE" ]; then
                stow_package "$SPECIFIC_PACKAGE" "restow"
            else
                print_error "Package '$SPECIFIC_PACKAGE' not found"
                exit 1
            fi
        else
            # Restow all packages
            echo "Restowing all packages..."
            while IFS= read -r package; do
                stow_package "$package" "restow"
            done < <(get_packages)
            print_success "All packages restowed successfully!"
        fi
        ;;

    unstow|uninstall)
        if [ -n "$SPECIFIC_PACKAGE" ]; then
            # Unstow specific package
            if [ -d "$DOTFILES_DIR/$SPECIFIC_PACKAGE" ]; then
                stow_package "$SPECIFIC_PACKAGE" "unstow"
            else
                print_error "Package '$SPECIFIC_PACKAGE' not found"
                exit 1
            fi
        else
            # Unstow all packages
            echo "Unstowing all packages..."
            while IFS= read -r package; do
                stow_package "$package" "unstow"
            done < <(get_packages)
            print_success "All packages unstowed successfully!"
        fi
        ;;

    list)
        echo "Available packages:"
        while IFS= read -r package; do
            echo "  - $package"
        done < <(get_packages)
        ;;

    help|--help|-h)
        cat << EOF
Dotfiles Stow Management Script

Usage: $0 [ACTION] [PACKAGE]

Actions:
  stow|install      Stow packages (create symlinks) [default]
  restow|update     Restow packages (recreate symlinks)
  unstow|uninstall  Unstow packages (remove symlinks)
  list              List available packages
  help              Show this help message

Examples:
  $0                    # Stow all packages
  $0 stow tmux          # Stow only tmux package
  $0 restow             # Restow all packages
  $0 unstow nvim        # Unstow nvim package
  $0 list               # List all available packages

EOF
        ;;

    *)
        print_error "Unknown action: $ACTION"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac
