#!/usr/bin/env bash
set -eu

sed -i "s/LOG=.*/LOG=\"false\"/" ./alis.conf
sed -i "s#DEVICE=.*#DEVICE=\"auto\"#" ./alis.conf
sed -i "s/FILE_SYSTEM_TYPE=.*/FILE_SYSTEM_TYPE=\"ext4\"/" ./alis.conf
sed -i "s/LVM=.*/LVM=\"true\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD=.*/LUKS_PASSWORD=\"\"/" ./alis.conf
sed -i "s/LUKS_PASSWORD_RETYPE=.*/LUKS_PASSWORD_RETYPE=\"\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD=.*/ROOT_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/ROOT_PASSWORD_RETYPE=.*/ROOT_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD=.*/USER_PASSWORD=\"archlinux\"/" ./alis.conf
sed -i "s/USER_PASSWORD_RETYPE=.*/USER_PASSWORD_RETYPE=\"archlinux\"/" ./alis.conf
sed -i "s/SYSTEMD_HOMED=.*/SYSTEMD_HOMED=\"true\"/" ./alis.conf
sed -i "s/SYSTEMD_HOMED_STORAGE=.*/SYSTEMD_HOMED_STORAGE=\"luks\"/" ./alis.conf
sed -i "s/SYSTEMD_HOMED_STORAGE_LUKS_TYPE=.*/SYSTEMD_HOMED_STORAGE_LUKS_TYPE=\"ext4\")/" ./alis.conf
sed -i "s/BOOTLOADER=.*/BOOTLOADER=\"systemd\"/" ./alis.conf

