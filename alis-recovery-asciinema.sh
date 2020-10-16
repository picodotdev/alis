#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2020 picodotdev

curl -o asciinema-2.0.2.zip https://github.com/asciinema/asciinema/archive/v2.0.2.zip
bsdtar -x -f asciinema-2.0.2.zip
cp -r asciinema-2.0.2/* .
rm -f alis.asciinema
python3 -m asciinema rec -i 5 ~/alis-recovery.asciinema