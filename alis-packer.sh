#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

CONFIG_FILE="alis-packer.json"
CONFIG_FILE_SH="alis-packer-efi-ext4-systemd.sh"

while getopts "c:" arg; do
  case $arg in
    c)
      CONFIG_FILE_SH="$OPTARG"
      ;;
  esac
done

packer validate "packer/$CONFIG_FILE"
packer build -force -on-error=ask -var "config_file_sh=$CONFIG_FILE_SH" "packer/$CONFIG_FILE"

