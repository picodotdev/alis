#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2020 picodotdev

curl -L -o asciinema-2.0.2.zip https://github.com/asciinema/asciinema/archive/v2.0.2.zip
unzip asciinema-2.0.2.zip
rm -f alis.asciinema
(cd asciinema-2.0.2 && python3 -m asciinema rec -i 5 ~/alis.asciinema)