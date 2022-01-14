#!/usr/bin/env bash
set -eu

sed -i "s/LOG=.*/LOG=\"false\"/" ./alis.conf
sed -i "s#DEVICE=.*#DEVICE=\"/dev/sda\"#" ./alis.conf
sed -i "s/FILE_SYSTEM_TYPE=.*/FILE_SYSTEM_TYPE=\"ext4\"/" ./alis.conf
sed -i "s/LVM=.*/LVM=\"true\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD=.*/LUKS_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD_RETYPE=.*/LUKS_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD=.*/ROOT_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD_RETYPE=.*/ROOT_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD=.*/USER_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD_RETYPE=.*/USER_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/BOOTLOADER=.*/BOOTLOADER=\"grub\"/" ./alis.conf
sed -i "s/DESKTOP_ENVIRONMENT=.*/DESKTOP_ENVIRONMENT=\"\"/" ./alis.conf
sed -i "s/PACKAGES_FLATPAK_INSTALL=.*/PACKAGES_FLATPAK_INSTALL=\"true\"/" ./alis.conf
sed -i "s/PACKAGES_SDKMAN_INSTALL=.*/PACKAGES_SDKMAN_INSTALL=\"true\"/" ./alis.conf
sed -i "s/PACKAGES_FLATPAK_CUSTOM=.*/PACKAGES_FLATPAK_CUSTOM=\"org.videolan.VLC\"/" ./alis.conf
sed -i "s/PACKAGES_SDKMAN_SDKS=.*/PACKAGES_SDKMAN_SDKS=\"java:17.0.1-tem\"/" ./alis.conf

