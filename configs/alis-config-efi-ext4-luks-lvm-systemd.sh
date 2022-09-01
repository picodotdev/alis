#!/usr/bin/env bash
set -eu

sed -i "s/LOG=.*/LOG=\"false\"/" ./alis.conf
sed -i "s#DEVICE=.*#DEVICE=\"auto\"#" ./alis.conf
sed -i "s/FILE_SYSTEM_TYPE=.*/FILE_SYSTEM_TYPE=\"ext4\"/" ./alis.conf
sed -i "s/LVM=.*/LVM=\"true\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD=.*/LUKS_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD_RETYPE=.*/LUKS_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD=.*/ROOT_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD_RETYPE=.*/ROOT_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD=.*/USER_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD_RETYPE=.*/USER_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/BOOTLOADER=.*/BOOTLOADER=\"systemd\"/" ./alis.conf
sed -i "s/DESKTOP_ENVIRONMENT=.*/DESKTOP_ENVIRONMENT=\"\"/" ./alis.conf

