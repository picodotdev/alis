#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2018 picodotdev

source alis.conf

if [ -f alis-recovery.asciinema ]; then
    mkdir -p /mnt/var/log
    cp alis-recovery.asciinema /mnt/var/log/alis-recovery.asciinema
fi

umount -R /mnt/boot
umount -R /mnt
reboot