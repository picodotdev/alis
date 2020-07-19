#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2018 picodotdev

wget https://github.com/asciinema/asciinema/archive/v2.0.1.zip -O asciinema-2.0.1.zip
bsdtar -x -f asciinema-2.0.1.zip
cp -r asciinema-2.0.1/* .
rm -f alis.asciinema
python3 -m asciinema rec -i 5 ~/alis.asciinema