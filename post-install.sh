
#!/usr/bin/env bash

USER_NAME="$(whoami)"
HOME_DIR="/home/$USER_NAME"
GIT_DIR="$HOME/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
ALIS_REPO="https://github.com/libertine89/alis"

# Install hyprland DE
    sudo pacman -S hyprland

# Make Git directory at /home/"username"/Git
    mkdir -p "$GIT_DIR"
# & clone dotfiles repo
    git clone "$DOTFILES_REPO" "$GIT_DIR"
# & clone alis repo
    git clone "$ALIS_REPO" "$GIT_DIR"
# & copy dotfiles from repo to correct place in /home
    cp -r "$GIT_DIR/dotfiles/." "$HOME_DIR/"
    chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR"


