#!/usr/bin/env bash
set -euo pipefail

########################################## VARIABLES ##########################################  

USER_NAME="$(whoami)"
HOME_DIR="/home/$USER_NAME"
GIT_DIR="$HOME_DIR/Git"
DOTFILES_REPO="https://github.com/libertine89/dotfiles"
ALIS_REPO="https://github.com/libertine89/alis"
SETUP_SCRIPT="$GIT_DIR/dotfiles/setup/setup-arch.sh"
SDDM_THEME="sugar-candy"
SDDM_THEMES_DIR="$GIT_DIR/dotfiles/sddm-themes"
THEME_DEPENDENCIES="qt5-graphicaleffects qt5-quickcontrols2 qt5-svg"

########################################## HELPERS ##########################################  

execute_step() {
    local step="$1"
    echo ">>> Running step: $step <<<"
    $step
}

print_step() {
    echo "=== $1 ==="
}

########################################## GIT & REPOS ##########################################  
packages_check(){
    # Check if stow installed
    if ! command -v stow &>/dev/null; then
    echo "Installing GNU Stow..."
    sudo pacman -S --noconfirm --needed stow
    fi

    # Check if sddm installed
        if ! pacman -Qi sddm &>/dev/null; then
        echo "Installing sddm..."
        sudo pacman -S --noconfirm --needed sddm
    fi

    # Ensure SDDM theme dependencies are installed
    for pkg in $THEME_DEPENDENCIES; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            echo "Installing missing package: $pkg"
            sudo pacman -S --noconfirm --needed "$pkg"
        fi
    done

    echo "All packages are installed ✅"
}

########################################## GIT & REPOS ##########################################  
clone_gits(){
    print_step "clone_gits"
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
}
########################################## DOTFILES ##########################################  
install_dotfiles(){
    print_step "install_dotfiles"
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
}

########################################## INSTAL SDDM THEME ##########################################  

install_sddm_theme() {
    print_step "install_sddm_theme"
    echo "Installing SDDM theme: $SDDM_THEME"

    sudo mkdir -p /usr/share/sddm/themes

    # Copy wallpapers into the selected theme folder
    echo "Copying wallpapers from $GIT_DIR/dotfiles/.config/ml4w/wallpapers into $SDDM_THEMES_DIR/$SDDM_THEME..."
    sudo cp -r "$GIT_DIR/dotfiles/.config/ml4w/wallpapers/"* "$SDDM_THEMES_DIR/$SDDM_THEME/"

    # Update theme.conf to set Background="default.jpg"
    THEME_CONF="$SDDM_THEMES_DIR/$SDDM_THEME/theme.conf"
    if [ -f "$THEME_CONF" ]; then
        echo "Updating background in $THEME_CONF..."
        sudo sed -i 's/^Background=.*/Background="default.jpg"/' "$THEME_CONF"
    else
        echo "Warning: $THEME_CONF not found!"
    fi

    # Copy all themes into /usr/share/sddm/themes
    echo "Copying all themes from $SDDM_THEMES_DIR into /usr/share/sddm/themes..."
    sudo cp -r "$SDDM_THEMES_DIR/"* /usr/share/sddm/themes/

    sudo mkdir -p /etc/sddm.conf.d

cat <<-EOT | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
[Theme]
Current=$SDDM_THEME
EOT
    echo "SDDM theme $SDDM_THEME installed and configured."
}

########################################## END ##########################################  

finish_script(){
    echo "Dotfiles dependencies, setup and stow complete. Rebooting now"
    sleep 10
    # Remove the script itself
    rm -f "$HOME_DIR/post-install.sh"
    reboot
}

########################################## MAIN LOOP ########################################## 

main(){
    # request sudo at start
    sudo -v 
    execute_step "packages_check"
    execute_step "clone_gits"
    execute_step "install_dotfiles"
    execute_step "install_sddm_theme"
    execute_step "finish_script"
}

main


