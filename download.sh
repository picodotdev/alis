#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

GITHUB_USER="picodotdev"
BRANCH="master"

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
curl -sL -o "alis-$BRANCH.zip" https://github.com/$GITHUB_USER/alis/archive/refs/heads/$BRANCH.zip
bsdtar -x -f "alis-$BRANCH.zip"
cp -R alis-$BRANCH/*.sh alis-$BRANCH/*.conf alis-$BRANCH/files/ ./
chmod +x *.sh
