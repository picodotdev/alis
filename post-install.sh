
#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(whoami)"
GIT_DIR="$HOME/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
DOTFILES_DIR="$GIT_DIR/dotfiles"

# Clone dotfiles
mkdir -p "$GIT_DIR"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Run setup script
bash "$DOTFILES_DIR/setup/setup-arch.sh"

# Copy dotfiles into $HOME
if [ -d "$DOTFILES_DIR/dotfiles" ]; then
    cp -r "$DOTFILES_DIR/dotfiles/." "$HOME/"
fi

# Disable this service so it only runs once
systemctl --user disable post-install.service
rm -f ~/.config/systemd/user/post-install.service

