#!/usr/bin/env bash
set -eu

sed -i "s/LOG=.*/LOG=\"false\"/" ./alis.conf
sed -i "s#DEVICE=.*#DEVICE=\"auto\"#" ./alis.conf
sed -i "s/FILE_SYSTEM_TYPE=.*/FILE_SYSTEM_TYPE=\"ext4\"/" ./alis.conf
sed -i "s/LVM=.*/LVM=\"false\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD=.*/LUKS_PASSWORD=\"\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD_RETYPE=.*/LUKS_PASSWORD_RETYPE=\"\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD=.*/ROOT_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD_RETYPE=.*/ROOT_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD=.*/USER_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD_RETYPE=.*/USER_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/BOOTLOADER=.*/BOOTLOADER=\"systemd\"/" ./alis.conf
sed -i "s/DESKTOP_ENVIRONMENT=.*/DESKTOP_ENVIRONMENT=\"gnome\"/" ./alis.conf
sed -i "s/PACKAGES_INSTALL=.*/PACKAGES_INSTALL=\"true\"/" ./alis.conf
sed -i "s/PACKAGES_INSTALL_PIPEWIRE=.*/PACKAGES_INSTALL_PIPEWIRE=\"false\"/" ./alis.conf
sed -i "s/PACKAGES_FLATPAK_INSTALL=.*/PACKAGES_FLATPAK_INSTALL=\"true\"/" ./alis-packages.conf
sed -i "s/PACKAGES_FLATPAK_CUSTOM=.*/PACKAGES_FLATPAK_CUSTOM=\"org.videolan.VLC\"/" ./alis-packages.conf
sed -i "s/PACKAGES_SDKMAN_INSTALL=.*/PACKAGES_SDKMAN_INSTALL=\"true\"/" ./alis-packages.conf
sed -i "s/PACKAGES_SDKMAN_SDKS=.*/PACKAGES_SDKMAN_SDKS=\"java:17.0.1-tem\"/" ./alis-packages.conf

