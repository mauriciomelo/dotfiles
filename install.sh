#!/bin/bash

set -e # Exit on error

echo "🚀 Starting MacBook Bootstrap..."

# 1. Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure brew for the current shell session
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed."
fi

# 2. Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "🛠️ Installing chezmoi..."
    brew install chezmoi
fi

# 3. Verify KeePass file exists
KDBX_PATH="$HOME/Sync/keys.kdbx"
if [ ! -f "$KDBX_PATH" ]; then
    echo "❌ Error: KeePass file not found at $KDBX_PATH"
    echo "Please add it before running this script."
    exit 1
fi

# 4. Initialize and Apply Dotfiles
# This will prompt you for your KeePass Master Password during the apply phase
echo "Applying configurations via chezmoi..."
if [ ! -d "$HOME/.local/share/chezmoi/.git" ]; then
    # First time setup: init and apply
    chezmoi init --apply --verbose https://github.com/mauriciomelo/dotfiles.git
else
    # Update existing setup
    chezmoi apply --verbose
fi

echo "✨ Setup complete! Please restart your terminal."