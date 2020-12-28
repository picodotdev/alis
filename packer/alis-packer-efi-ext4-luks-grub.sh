#!/usr/bin/env bash
set -e

sed -i "s/LOG=.*/LOG=\"true\"/" ./alis.conf
sed -i "s/FILE_SYSTEM_TYPE=.*/FILE_SYSTEM_TYPE=\"ext4\"/" ./alis.conf
sed -i "s/LVM=.*/LVM=\"false\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD=.*/LUKS_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD_RETYPE=.*/LUKS_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD=.*/ROOT_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD_RETYPE=.*/ROOT_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD=.*/USER_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD_RETYPE=.*/USER_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/BOOTLOADER=.*/BOOTLOADER=\"grub\"/" ./alis.conf
sed -i "s/DESKTOP_ENVIRONMENT=.*/DESKTOP_ENVIRONMENT=\"\"/" ./alis.conf
sed -i "s/PACKAGES_FLATPAK_CUSTOM=.*/PACKAGES_FLATPAK_CUSTOM=\"org.videolan.VLC\"/" ./alis.conf
sed -i "s/PACKAGES_SDKMAN_SDKS=.*/PACKAGES_SDKMAN_SDKS=\"java:11.0.7-open\"/" ./alis.conf
