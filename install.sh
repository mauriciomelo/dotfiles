#!/bin/bash

set -e # Exit on error

echo "🚀 Starting MacBook Bootstrap..."

# Install Homebrew if not present
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

# Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "🛠️ Installing chezmoi..."
    brew install chezmoi
fi

# Install bitwarden CLI
if ! command -v bw &> /dev/null; then
    echo "🔐 Installing Bitwarden CLI..."
    brew install bitwarden-cli

    # Configure Bitwarden
    echo "🔒 Configuring Bitwarden..."
    bw config server https://vault.bitwarden.eu
fi


# Login to Bitwarden if needed
if ! bw login --check; then
    echo "🔓 Logging into Bitwarden..."
    export BW_SESSION=$(bw login --raw)
fi

 # Unlock Bitwarden if needed
if ! bw unlock --check; then
    echo "🔓 Unlocking Bitwarden..."
    export BW_SESSION=$(bw unlock --raw)
fi

# Sync Bitwarden Vault
bw sync


# Initialize and Apply Dotfiles
# This will prompt you for your KeePass Master Password during the apply phase
echo "Applying configurations via chezmoi..."
if [ ! -d "$HOME/.local/share/chezmoi/.git" ]; then
    # First time setup: init and apply
    chezmoi init --apply --verbose https://github.com/mauriciomelo/dotfiles.git
else
    # Update existing setup
    chezmoi update --apply --verbose
fi

echo "✨ Setup complete! Please restart your terminal."