#!/usr/bin/env bash
#shellcheck disable=SC1091
#SC1091: Can't follow non-constant source. Use a directive to specify location.
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

source "alis-commons.sh"

do_reboot

