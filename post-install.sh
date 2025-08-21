#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(whoami)"
HOME_DIR="/home/$USER_NAME"
GIT_DIR="$HOME_DIR/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
ALIS_REPO="https://github.com/libertine89/alis"

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

# Use GNU Stow to symlink dotfiles into home directory
echo "Stowing dotfiles into $HOME_DIR..."
cd "$GIT_DIR/dotfiles" || exit 1
stow --target="$HOME_DIR" dotfiles

# Ensure the symlinked files are owned by the user
chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR"




