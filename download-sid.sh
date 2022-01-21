#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

GITHUB_USER="picodotdev"
BRANCH="sid"

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

set -o xtrace
pacman -Sy --noconfirm git
git clone --depth 1 --branch "$BRANCH" "https://github.com/$GITHUB_USER/alis.git"
cp -R alis/*.sh alis/*.conf alis/files/ ./
chmod +x *.sh

