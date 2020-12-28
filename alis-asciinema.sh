#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2020 picodotdev

#curl -L -o asciinema-2.0.2.zip https://github.com/asciinema/asciinema/archive/v2.0.2.zip
#bsdtar xvf asciinema-2.0.2.zip
#rm -f alis.asciinema
#(cd asciinema-2.0.2 && python3 -m asciinema rec --stdin -i 5 ~/alis.asciinema)

#pacman -U --noconfirm \
#    https://archive.archlinux.org/repos/2020/11/30/community/os/x86_64/asciinema-2.0.2-3-any.pkg.tar.xz \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-setuptools-1%3A50.3.2-1-any.pkg.tar.zst \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-appdirs-1.4.4-1-any.pkg.tar.zst \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-ordered-set-4.0.2-1-any.pkg.tar.zst \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-packaging-20.4-1-any.pkg.tar.zst \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-six-1.15.0-1-any.pkg.tar.zst \
#    https://archive.archlinux.org/repos/2020/11/30/extra/os/x86_64/python-pyparsing-2.4.7-1-any.pkg.tar.zst

pacman -S --noconfirm asciinema
clear && cat /etc/motd
asciinema rec --stdin -i 5 ~/alis.asciinema
