#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2021 picodotdev

function do_reboot() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

do_reboot
