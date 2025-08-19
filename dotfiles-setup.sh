#!/usr/bin/env bash

USER="arcius"
MNT="/mnt"
USER_HOME="$MNT/home/$USER"
GIT_DIR="$USER_HOME/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
DOTFILES_DIR="$GIT_DIR/dotfiles"

# Ensure the user home exists
if [ ! -d "$USER_HOME" ]; then
    echo "Error: $USER_HOME does not exist. Did you create the user $USER in the target system?"
    exit 1
fi
chown -R "$USER:$USER" "$USER_HOME"

# Create Git directory
arch-chroot "$MNT" sudo -u "$USER" mkdir -p "$GIT_DIR"

# Clone dotfiles repo (fresh)
arch-chroot "$MNT" sudo -u "$USER" bash -c "rm -rf '$DOTFILES_DIR' && git clone '$DOTFILES_REPO' '$DOTFILES_DIR'"

# Run the setup script inside the installed system as user
arch-chroot "$MNT" sudo -u "$USER" bash "$DOTFILES_DIR/setup/setup-arch.sh"

# Copy dotfiles into user home
cp -r "$DOTFILES_DIR/dotfiles/." "$USER_HOME/"

# Fix ownership
chown -R "$USER:$USER" "$USER_HOME"

echo ":: Dotfiles setup completed successfully for $USER in $MNT"
