#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2020 picodotdev

function terminate() {
    cp "$CONF_FILE" "/mnt/etc/$CONF_FILE"

    if [ "$LOG" == "true" ]; then
        mkdir -p /mnt/var/log/alis
        cp "$LOG_FILE" "/mnt/var/log/alis/$LOG_FILE"
    fi
    if [ "$ASCIINEMA" == "true" ]; then
        mkdir -p /mnt/var/log/alis
        cp "$ASCIINEMA_FILE" "/mnt/var/log/alis/$ASCIINEMA_FILE"
    fi
}

function end() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

terminate
end
