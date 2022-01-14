#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

LOG_FILE="alis-packages.log"
ASCIINEMA_FILE="alis-packages.asciinema"

function copy_logs() {
    if [ -f "$LOG_FILE" ]; then
        sudo mkdir -p /var/log/alis
        sudo cp "$LOG_FILE" "/var/log/alis/$LOG_FILE"
    fi
    if [ -f "$ASCIINEMA_FILE" ]; then
        sudo mkdir -p /var/log/alis
        sudo cp "$ASCIINEMA_FILE" "/var/log/alis/$ASCIINEMA_FILE"
    fi
}

copy_logs

