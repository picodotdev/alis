#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

GITHUB_USER="picodotdev"
BRANCH="master"
HASH=""

while getopts "b:h:u:" arg; do
  case ${arg} in
    b)
      BRANCH="${OPTARG}"
      ;;
    h)
      HASH="${OPTARG}"
      ;;
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
if [ -n "$HASH" ]; then
  curl -sL -o "alis-$HASH.zip" https://github.com/$GITHUB_USER/alis/archive/$HASH.zip
  bsdtar -x -f "alis-$HASH.zip"
  cp -R alis-$HASH/*.sh alis-$HASH/*.conf alis-$HASH/files/ alis-$HASH/configs/ ./
else
  curl -sL -o "alis-$BRANCH.zip" https://github.com/$GITHUB_USER/alis/archive/refs/heads/$BRANCH.zip
  bsdtar -x -f "alis-$BRANCH.zip"
  cp -R alis-$BRANCH/*.sh alis-$BRANCH/*.conf alis-$BRANCH/files/ alis-$BRANCH/configs/ ./
fi
chmod +x configs/*.sh
chmod +x *.sh
