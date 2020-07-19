#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2018 picodotdev

rm -f alis.conf
rm -f alis.sh
rm -f alis-asciinema.sh
rm -f alis-reboot.sh

rm -f alis-recovery.conf
rm -f alis-recovery.sh
rm -f alis-recovery-asciinema.sh
rm -f alis-recovery-reboot.sh

curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis.conf
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis.sh
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-asciinema.sh
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-reboot.sh

curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-recovery.conf
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-recovery.sh
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-recovery-asciinema.sh
curl -O https://raw.githubusercontent.com/picodotdev/alis/sid/alis-recovery-reboot.sh

chmod +x alis.sh
chmod +x alis-asciinema.sh
chmod +x alis-reboot.sh

chmod +x alis-recovery.sh
chmod +x alis-recovery-asciinema.sh
chmod +x alis-recovery-reboot.sh
