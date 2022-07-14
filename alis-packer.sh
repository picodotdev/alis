#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

CONFIG_FILE="alis-packer.json"
BRANCH="master"
BRANCH_QUALIFIER=""
CONFIG_FILE_SH="alis-config-efi-ext4-systemd.sh"

while getopts "b:c:" arg; do
  case $arg in
    b)
      BRANCH="$OPTARG"
      ;;
    c)
      CONFIG_FILE_SH="$OPTARG"
      ;;
    *) 
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

if [ "$BRANCH" == "sid" ]; then
  BRANCH_QUALIFIER="-sid"
fi

packer validate "packer/$CONFIG_FILE"
packer build -force -on-error=ask -var "branch=$BRANCH branch_qualifier=$BRANCH_QUALIFIER config_file_sh=$CONFIG_FILE_SH" "configs/$CONFIG_FILE"

