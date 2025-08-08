#!/usr/bin/env bash
#
# install-dotfiles.sh
# Run inside alis after user creation to clone and stow your dotfiles
#

# --- CONFIG ---
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

# --- Ensure required packages ---
echo ":: Installing git and stow..."
if ! pacman -Qi git &>/dev/null; then
    sudo pacman --noconfirm -S git
fi
if ! pacman -Qi stow &>/dev/null; then
    sudo pacman --noconfirm -S stow
fi

# --- Clone the repo ---
if [ -d "$DOTFILES_DIR" ]; then
    echo ":: Dotfiles directory already exists at $DOTFILES_DIR"
    echo ":: Pulling latest changes..."
    git -C "$DOTFILES_DIR" pull
else
    echo ":: Cloning dotfiles repo..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- Stow the dotfiles ---
echo ":: Stowing dotfiles into $HOME"
cd "$DOTFILES_DIR" || { echo "!! Could not cd into $DOTFILES_DIR"; exit 1; }

# Stow .config folder
if [ -d ".config" ]; then
    stow --target="$HOME" .config
fi

# Stow any top-level files or other folders (optional)
for item in .*; do
    case "$item" in
        .|..|.git|.config) continue ;;
        *)
            if [ -e "$item" ]; then
                stow --target="$HOME" "$item"
            fi
            ;;
    esac
done

echo ":: Dotfiles installation complete."
