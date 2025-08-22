#!/usr/bin/env bash
set -euo pipefail
# request sudo at start
sudo -v 
########################################## VARIABLES ##########################################  

USER_NAME="$(whoami)"
HOME_DIR="/home/$USER_NAME"
GIT_DIR="$HOME_DIR/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
ALIS_REPO="https://github.com/libertine89/alis"
SETUP_SCRIPT="$GIT_DIR/dotfiles/setup/setup-arch.sh"

########################################## GIT & REPOS ##########################################  

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

########################################## DOTFILES ##########################################  

# Run setup script for dependencys for dotfiles etc
if [ -f "$SETUP_SCRIPT" ]; then
    echo "Running setup-arch.sh..."
    chmod +x "$SETUP_SCRIPT"
    "$SETUP_SCRIPT"
else
    echo "setup-arch.sh not found in $SETUP_SCRIPT"
fi

# Backup existing dotfiles if they exist
if [ -f "$HOME_DIR/.bashrc" ]; then
    mv "$HOME_DIR/.bashrc" "$HOME_DIR/.bashrc.backup"
    echo "Backed up existing .bashrc to .bashrc.backup"
fi

if [ -f "$HOME_DIR/.config/hypr/hyprland.conf" ]; then
    mv "$HOME_DIR/.config/hypr/hyprland.conf" "$HOME_DIR/.config/hypr/hyprland.conf.backup"
    echo "Backed up existing hyprland.conf to hyprland.conf.backup"
fi
# Use GNU Stow to symlink dotfiles into home directory
echo "Stowing dotfiles into $HOME_DIR..."
cd "$GIT_DIR/dotfiles" || exit 1
stow --target="$HOME_DIR" dotfiles


########################################## SPLASH SCREEN ##########################################  

echo "Installing Plymouth and default theme..."

# Install Plymouth and the default spinner theme
pacman -S --noconfirm plymouth plymouth-theme-spinner

# Set the default theme and rebuild initramfs
plymouth-set-default-theme -R spinner

# Ensure the kernel command line includes 'quiet splash' for smooth boot
LOADER_CONF="/boot/loader/entries/arch.conf"
if [ -f "$LOADER_CONF" ] && ! grep -q "splash" "$LOADER_CONF"; then
    sed -i 's/^\(options.*\)$/\1 splash/' "$LOADER_CONF"
fi

echo "Plymouth installed with default spinner theme."

########################################## END ##########################################  

echo "Dotfiles dependencies, setup and stow complete. Rebooting now"
sleep 10
# Remove the script itself
rm -f "$HOME_DIR/post-install.sh"
reboot






