#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2020 picodotdev

source alis.conf

if [ -f alis.asciinema ]; then
    mkdir -p /mnt/var/log
    cp alis.asciinema /mnt/var/log/alis.asciinema
fi

umount -R /mnt/boot
umount -R /mnt
reboot