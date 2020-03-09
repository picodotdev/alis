#!/usr/bin/env bash
set -e

wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.conf
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.sh
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis-packer.sh
mkdir -p packer/
wget -O packer/alis-packer-efi-btrfs-luks-lvm-systemd.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-btrfs-luks-lvm-systemd.json
wget -O packer/alis-packer-efi-ext4-grub-gnome.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-ext4-grub-gnome.json
wget -O packer/alis-packer-efi-ext4-grub-kde.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-ext4-grub-kde.json
wget -O packer/alis-packer-efi-ext4-grub-xfce.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-ext4-grub-xfce.json
wget -O packer/alis-packer-efi-ext4-luks-lvm-grub.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-ext4-luks-lvm-grub.json
wget -O packer/alis-packer-efi-f2fs-luks-lvm-systemd.json https://raw.githubusercontent.com/picodotdev/alis/master/packer/alis-packer-efi-f2fs-luks-lvm-systemd.json

chmod +x ./alis-packer.sh
./alis-packer.sh
