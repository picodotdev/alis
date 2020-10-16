#!/usr/bin/env bash
set -e

GITHUB_USER="picodotdev"

while getopts "u:" arg; do
  case ${arg} in
    u)
      GITHUB_USER=${OPTARG}
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done

curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis/master/alis.conf
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis/master/alis.sh
curl -O https://raw.githubusercontent.com/$GITHUB_USER/alis/master/alis-packer.sh
mkdir -p packer/
curl -o packer/alis-packer-efi-btrfs-luks-lvm-systemd.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-btrfs-luks-lvm-systemd.json
curl -o packer/alis-packer-efi-ext4-grub-gnome.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-ext4-grub-gnome.json
curl -o packer/alis-packer-efi-ext4-grub-kde.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-ext4-grub-kde.json
curl -o packer/alis-packer-efi-ext4-grub-i3-wm.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-ext4-grub-i3-wm.json
curl -o packer/alis-packer-efi-ext4-grub-xfce.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-ext4-grub-xfce.json
curl -o packer/alis-packer-efi-ext4-luks-lvm-grub.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-ext4-luks-lvm-grub.json
curl -o packer/alis-packer-efi-f2fs-luks-lvm-systemd.json https://raw.githubusercontent.com/$GITHUB_USER/alis/master/packer/alis-packer-efi-f2fs-luks-lvm-systemd.json

chmod +x ./alis-packer.sh
./alis-packer.sh
