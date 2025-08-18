#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --------------------------------------------------------------
# Detect running from live ISO
# --------------------------------------------------------------

if grep -q "archiso" /etc/os-release 2>/dev/null; then
    echo ":: Detected running from live ISO. Will chroot into /mnt automatically."

    # Ensure target is mounted
    TARGET=/mnt
    if [ ! -d "$TARGET" ]; then
        echo "ERROR: Target root ($TARGET) does not exist or is not mounted."
        exit 1
    fi

    # Mount pseudo-filesystems for chroot
    mount --bind /dev $TARGET/dev
    mount --bind /proc $TARGET/proc
    mount --bind /sys $TARGET/sys
    mount --bind /run $TARGET/run 2>/dev/null || true

    # Copy script into target (optional)
    cp -r $SCRIPT_DIR $TARGET/tmp/setup-arch

    echo ":: Entering chroot..."
    chroot $TARGET /bin/bash -c "/tmp/setup-arch/setup-arch.sh"
    exit 0
fi

# --------------------------------------------------------------
# Library
# --------------------------------------------------------------
source $SCRIPT_DIR/_lib.sh

# --------------------------------------------------------------
# Arrays / packages
# --------------------------------------------------------------
source $SCRIPT_DIR/pkgs.sh

packages=(
    # Hyprland
    "hyprland"
    "libnotify"
    "qt5-wayland"
    "qt6-wayland"
    "uwsm"
    "python-pip"
    "python-gobject"
    "python-screeninfo"
    "nm-connection-editor"
    "network-manager-applet"
    "imagemagick"
    "polkit-gnome"
    "hyprshade"
    "grimblast-git"
    "checkupdates-with-aur"
    "loupe"
    "power-profiles-daemon"
    # Apps
    "waypaper"
    "swaync"
    # Tools
    "eza"
    "python-pywalfox"
    # Themes
    "papirus-icon-theme"
    "breeze"
    # Fonts
    "otf-font-awesome"
    "ttf-fira-sans"
    "ttf-fira-code"
    "ttf-firacode-nerd"
    "ttf-dejavu"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "noto-fonts-extra"
)

# --------------------------------------------------------------
# Functions (install, yay, etc.)
# --------------------------------------------------------------

_isInstalled() {
    package="$1"
    check="$(pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")"
    if [ -n "${check}" ]; then
        echo 0
        return #true
    fi
    echo 1
    return #false
}

_installYay() {
    if [[ ! $(_isInstalled "base-devel") == 0 ]]; then
        pacman --noconfirm -S "base-devel"
    fi
    if [[ ! $(_isInstalled "git") == 0 ]]; then
        pacman --noconfirm -S "git"
    fi

    TEMP_DIR=/tmp/yay-bin
    rm -rf $TEMP_DIR
    git clone https://aur.archlinux.org/yay-bin.git $TEMP_DIR
    cd $TEMP_DIR
    makepkg -si
    cd -
    echo ":: yay has been installed successfully."
}

_installPackages() {
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo ":: ${pkg} is already installed."
            continue
        fi
        yay --noconfirm -S "${pkg}"
    done
}

# --------------------------------------------------------------
# Set HOME properly (for chroot installs, e.g., dotfiles)
# --------------------------------------------------------------
if [ -z "$HOME" ] || [ "$HOME" == "/root" ]; then
    if [ -d /home/arcius ]; then
        export HOME=/home/arcius
    else
        export HOME=/root
    fi
fi

mkdir -p $HOME/.local/bin

# --------------------------------------------------------------
# Main installation
# --------------------------------------------------------------

# gum
if command -v gum >/dev/null 2>&1; then
    echo ":: gum is already installed"
else
    echo ":: Installing gum"
    pacman --noconfirm -S gum
fi

# yay
if ! command -v yay >/dev/null 2>&1; then
    echo ":: Installing yay"
    _installYay
fi

# Install arrays
_installPackages "${general[@]}"
_installPackages "${apps[@]}"
_installPackages "${tools[@]}"
_installPackages "${packages[@]}"

# Other scripts
source $SCRIPT_DIR/_prebuilt.sh
source $SCRIPT_DIR/_ml4w-apps.sh
source $SCRIPT_DIR/_flatpaks.sh
source $SCRIPT_DIR/_cursors.sh
source $SCRIPT_DIR/_fonts.sh

# Finish
_finishMessage