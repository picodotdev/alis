#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(whoami)"
HOME_DIR="/home/$USER_NAME"
GIT_DIR="$HOME_DIR/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
ALIS_REPO="https://github.com/libertine89/alis"

# Check if Hyprland is installed, install if missing
if ! pacman -Qi hyprland &>/dev/null; then
    echo "Installing Hyprland..."
    sudo pacman -S --noconfirm hyprland
else
    echo "Hyprland already installed, skipping."
fi

# Ensure Git directory exists
mkdir -p "$GIT_DIR"

# Clone dotfiles repo if not already present
if [ ! -d "$GIT_DIR/dotfiles/.git" ]; then
    echo "Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$GIT_DIR/dotfiles"
else
    echo "Dotfiles repo already exists, pulling latest changes..."
    git -C "$GIT_DIR/dotfiles" pull
fi

# Clone alis repo if not already present
if [ ! -d "$GIT_DIR/alis/.git" ]; then
    echo "Cloning alis repo..."
    git clone "$ALIS_REPO" "$GIT_DIR/alis"
else
    echo "Alis repo already exists, pulling latest changes..."
    git -C "$GIT_DIR/alis" pull
fi

# Copy dotfiles into home directory
echo "Copying dotfiles into $HOME_DIR..."
cp -r "$GIT_DIR/dotfiles/dotfiles/." "$HOME_DIR/"
chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR"



