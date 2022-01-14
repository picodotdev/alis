#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

#curl -L -o asciinema-2.0.2.zip https://github.com/asciinema/asciinema/archive/v2.0.2.zip
#bsdtar xvf asciinema-2.0.2.zip
#rm -f alis.asciinema
#(cd asciinema-2.0.2 && python3 -m asciinema rec --stdin -i 5 ~/alis.asciinema)

rm -f alis-packages.asciinema

#pacman -S --noconfirm asciinema

clear
asciinema rec --stdin -i 5 ~/alis-packages.asciinema

