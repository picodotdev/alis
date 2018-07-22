#!/usr/bin/env bash
set -e

# Arch Linux Install Script Recovery (alis-recovery) start a recovery for an
# failed installation or broken system.
# Copyright (C) 2018 picodotdev

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# This script is hosted at https://github.com/picodotdev/alis. For new features,
# improvements and bugs fill an issue in GitHub or make a pull request.
# Pull Request are welcome!
#
# If you test it in real hardware please send me an email to pico.dev@gmail.com with
# the machine description and tell me if somethig goes wrong or all works fine.
#
# Please, don't ask for support for this script in Arch Linux forums, first read
# the Arch Linux wiki [1], the Installation Guide [2] and the General
# Recomendations [3], later compare the commands with those of this script.
#
# [1] https://wiki.archlinux.org
# [2] https://wiki.archlinux.org/index.php/Installation_guide
# [3] https://wiki.archlinux.org/index.php/General_recommendations

# Reference:
# * [Change root](https://wiki.archlinux.org/index.php/Change_root)
# * [Deactivate volume group](https://wiki.archlinux.org/index.php/LVM#Deactivate_volume_group)

# Usage:
# # loadkeys es
# # curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# # vim alis-recovery.conf
# # ./alis-recovery.sh

# global variables (no configuration, don't edit)
BIOS_TYPE=""
PARTITION_BIOS=""
PARTITION_BOOT=""
PARTITION_ROOT=""
DEVICE_ROOT=""
LVM_PHISICAL_VOLUME="lvm"
LVM_VOLUME_GROUP="vg"
LVM_VOLUME_LOGICAL="root"
BOOT_DIRECTORY=""
ESP_DIRECTORY=""
PARTITION_BOOT_NUMBER=0
UUID_BOOT=""
UUID_ROOT=""
PARTUUID_BOOT=""
PARTUUID_ROOT=""
DEVICE_TRIM=""
ALLOW_DISCARDS=""
CPU_INTEL=""
VIRTUALBOX=""
CMDLINE_LINUX_ROOT=""
CMDLINE_LINUX=""
ADDITIONAL_USER_NAMES_ARRAY=()
ADDITIONAL_USER_PASSWORDS_ARRAY=()
MODULES=""

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source alis-recovery.conf
}

function check_variables() {
    check_variables_value "KEYS" "$KEYS"
    check_variables_value "DEVICE" "$DEVICE"
    check_variables_boolean "LVM" "$LVM"
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
}

function check_variables_value() {
    NAME=$1
    VALUE=$2
    if [ -z "$VALUE" ]; then
        echo "$NAME environment variable must have a value."
        exit
    fi
}

function check_variables_boolean() {
    NAME=$1
    VALUE=$2
    check_variables_list "$NAME" "$VALUE" "true false"
}

function check_variables_list() {
    NAME=$1
    VALUE=$2
    VALUES=$3
    REQUIRED=$4
    if [ "$REQUIRED" == "" -o "$REQUIRED" == "true" ]; then
        check_variables_value "$NAME" "$VALUE"
    fi

    if [ "$VALUE" != "" -a -z "$(echo "$VALUES" | grep -F -w "$VALUE")" ]; then
        echo "$NAME environment variable value [$VALUE] must be in [$VALUES]."
        exit
    fi
}

function check_variables_size() {
    NAME=$1
    SIZE_EXPECT=$2
    SIZE=$3
    if [ "$SIZE_EXPECT" != "$SIZE" ]; then
        echo "$NAME array size [$SIZE] must be [$SIZE_EXPECT]."
        exit
    fi
}

function warning() {
    echo -e "${LIGHT_BLUE}Welcome to Arch Linux Install Script Recovery${NC}"
    echo ""
    echo "Once finalized recovery tasks execute following commands: exit, umount -R /mnt, reboot."
    echo ""
    read -p "Do you want to continue? [y/n] " yn
    case $yn in
        [Yy]* )
            ;;
        [Nn]* )
            exit
            ;;
        * )
            exit
            ;;
    esac
}

function init() {
    loadkeys $KEYS
}

function facts() {
    if [ -d /sys/firmware/efi ]; then
        BIOS_TYPE="uefi"
    else
        BIOS_TYPE="bios"
    fi

    if [ -n "$(hdparm -I $DEVICE | grep TRIM)" ]; then
        DEVICE_TRIM="true"
    else
        DEVICE_TRIM="false"
    fi

    if [ -n "$(lscpu | grep GenuineIntel)" ]; then
        CPU_INTEL="true"
    fi

    if [ -n "$(lspci | grep -i virtualbox)" ]; then
        VIRTUALBOX="true"
    fi
}

function prepare() {
    prepare_partition
}

function prepare_partition() {
    if [ -d /mnt/boot ]; then
        umount /mnt/boot
        umount /mnt
    fi
    if [ -e "/dev/mapper/$LVM_VOLUME_LOGICAL" ]; then
        if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
            cryptsetup close $LVM_VOLUME_LOGICAL
        fi
    fi
    if [ -e "/dev/mapper/$LVM_PHISICAL_VOLUME" ]; then
        if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
            cryptsetup close $LVM_PHISICAL_VOLUME
        fi
    fi
}

function configure_network() {
    if [ -n "$WIFI_INTERFACE" ]; then
        cp /etc/netctl/examples/wireless-wpa /etc/netctl
      	chmod 600 /etc/netctl

      	sed -i 's/^Interface=.*/Interface='"$WIFI_INTERFACE"'/' /etc/netctl
      	sed -i 's/^ESSID=.*/ESSID='"$WIFI_ESSID"'/' /etc/netctl
      	sed -i 's/^Key=.*/Key='\''$WIFI_KEY'\''/' /etc/netctl
      	if [ "$WIFI_HIDDEN" == "true" ]; then
      		sed -i 's/^#Hidden=.*/Hidden=yes/' /etc/netctl
      	fi

      	netctl start wireless-wpa
    fi

    ping -c 5 $PING_HOSTNAME
    if [ $? -ne 0 ]; then
        echo "Network ping check failed."
    fi
}

function partition() {
    if [ "$BIOS_TYPE" == "uefi" ]; then
        PARTITION_BOOT="/dev/sda1"
        PARTITION_ROOT="/dev/sda2"
        PARTITION_BOOT_NUMBER=1
        DEVICE_ROOT="/dev/sda2"
        DEVICE_ROOT_MAPPER="root"
    fi

    if [ "$BIOS_TYPE" == "bios" ]; then
        PARTITION_BIOS="/dev/sda1"
        PARTITION_BOOT="/dev/sda2"
        PARTITION_ROOT="/dev/sda3"
        PARTITION_BOOT_NUMBER=2
        DEVICE_ROOT="/dev/sda3"
        DEVICE_ROOT_MAPPER="root"
    fi

    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT_MAPPER="lvm"
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        echo -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" | cryptsetup --key-file=- open $PARTITION_ROOT $DEVICE_ROOT_MAPPER
        sleep 5

        DEVICE_ROOT="/dev/mapper/$DEVICE_ROOT_MAPPER"
    fi

    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT_MAPPER="lvm-lvroot"
        DEVICE_ROOT="/dev/mapper/$DEVICE_ROOT_MAPPER"
    fi

    MOUNT_OPTIONS=""

    if [ "$DEVICE_TRIM" == "true" ]; then
        MOUNT_OPTIONS="defaults,noatime,discard"
    fi

    mount -o "$MOUNT_OPTIONS" $DEVICE_ROOT /mnt
    mount -o "$MOUNT_OPTIONS" $PARTITION_BOOT /mnt/boot
}

function recovery() {
    arch-chroot /mnt
}

function main() {
    configuration_install
    check_variables
    warning
    init
    facts
    prepare
    partition
    #recovery
}

main
