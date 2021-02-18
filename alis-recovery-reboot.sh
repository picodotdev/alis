#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2021 picodotdev

LOG_FILE="alis-recovery.log"
ASCIINEMA_FILE="alis-recovery.asciinema"

function copy_logs() {
    if [ -f "$LOG_FILE" ]; then
        SOURCE_FILE="$LOG_FILE"
        FILE="/mnt/var/log/alis/$LOG_FILE"

        mkdir -p /mnt/var/log/alis
        cp "$SOURCE_FILE" "$FILE"
        chown root:root "$FILE"
        chmod 600 "$FILE"
    fi
    if [ -f "$ASCIINEMA_FILE" ]; then
        SOURCE_FILE="$ASCIINEMA_FILE"
        FILE="/mnt/var/log/alis/$ASCIINEMA_FILE"

        mkdir -p /mnt/var/log/alis
        cp "$SOURCE_FILE" "$FILE"
        chown root:root "$FILE"
        chmod 600 "$FILE"
    fi
}

function do_reboot() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

copy_logs
do_reboot