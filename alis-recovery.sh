#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2153,SC2155,SC2034
#SC1090: Can't follow non-constant source. Use a directive to specify location.
#SC2153: Possible Misspelling: MYVARIABLE may not be assigned. Did you mean MY_VARIABLE?
#SC2155 Declare and assign separately to avoid masking return values
#SC2034: foo appears unused. Verify it or export it.
set -eu

# Arch Linux Install Script Recovery (alis-recovery) start a recovery for an
# failed installation or broken system.
# Copyright (C) 2022 picodotdev

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

# Starts the reccovery of a Arch Linux system installed with alis.
#
# Usage:
# # loadkeys es
# # curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
# # vim alis-recovery.conf
# # ./alis-recovery.sh

function init_config() {
    local COMMONS_FILE="alis-commons.sh"

    source "$COMMONS_FILE"
    source "$COMMONS_CONF_FILE"
    source "$RECOVERY_CONF_FILE"
}

function sanitize_variables() {
    DEVICE=$(sanitize_variable "$DEVICE")
    FILE_SYSTEM_TYPE=$(sanitize_variable "$FILE_SYSTEM_TYPE")
    PARTITION_MODE=$(sanitize_variable "$PARTITION_MODE")
    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    PARTITION_CUSTOMMANUAL_BOOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_BOOT")
    PARTITION_CUSTOMMANUAL_ROOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_ROOT")

    for I in "${BTRFS_SUBVOLUMES_MOUNTPOINTS[@]}"; do
        IFS=',' read -ra SUBVOLUME <<< "$I"
        if [ "${SUBVOLUME[0]}" == "root" ]; then
            BTRFS_SUBVOLUME_ROOT=("${SUBVOLUME[@]}")
        elif [ "${SUBVOLUME[0]}" == "swap" ]; then
            BTRFS_SUBVOLUME_SWAP=("${SUBVOLUME[@]}")
        fi
    done

    for I in "${PARTITION_MOUNT_POINTS[@]}"; do
        IFS='=' read -ra PARTITION_MOUNT_POINT <<< "$I"
        if [ "${PARTITION_MOUNT_POINT[1]}" == "/boot" ]; then
            PARTITION_BOOT_NUMBER="${PARTITION_MOUNT_POINT[0]}"
        elif [ "${PARTITION_MOUNT_POINT[1]}" == "/" ]; then
            PARTITION_ROOT_NUMBER="${PARTITION_MOUNT_POINT[0]}"
        fi
    done
}

function check_variables() {
    check_variables_value "KEYS" "$KEYS"
    check_variables_boolean "LOG_TRACE" "$LOG_TRACE"
    check_variables_boolean "LOG_FILE" "$LOG_FILE"
    check_variables_value "DEVICE" "$DEVICE"
    if [ "$DEVICE" == "auto" ]; then
        local DEVICE_BOOT=$(lsblk -oMOUNTPOINT,PKNAME -P -M | grep 'MOUNTPOINT="/run/archiso/bootmnt"' | sed 's/.*PKNAME="\(.*\)".*/\1/')
        if [ -n "$DEVICE_BOOT" ]; then
            local DEVICE_BOOT="/dev/$DEVICE_BOOT"
        fi
        local DEVICE_DETECTED="false"
        if [ -e "/dev/sda" ] && [ "$DEVICE_BOOT" != "/dev/sda" ]; then
            if [ "$DEVICE_DETECTED" == "true" ]; then
                echo "Auto device is ambigous, detected $DEVICE and /dev/sda."
                exit 1
            fi
            DEVICE_DETECTED="true"
            DEVICE_SDA="true"
            DEVICE="/dev/sda"
        fi
        if [ -e "/dev/nvme0n1" ] && [ "$DEVICE_BOOT" != "/dev/nvme0n1" ]; then
            if [ "$DEVICE_DETECTED" == "true" ]; then
                echo "Auto device is ambigous, detected $DEVICE and /dev/nvme0n1."
                exit 1
            fi
            DEVICE_DETECTED="true"
            DEVICE_NVME="true"
            DEVICE="/dev/nvme0n1"
        fi
        if [ -e "/dev/vda" ] && [ "$DEVICE_BOOT" != "/dev/vda" ]; then
            if [ "$DEVICE_DETECTED" == "true" ]; then
                echo "Auto device is ambigous, detected $DEVICE and /dev/vda."
                exit 1
            fi
            DEVICE_DETECTED="true"
            DEVICE_VDA="true"
            DEVICE="/dev/vda"
        fi
        if [ -e "/dev/mmcblk0" ] && [ "$DEVICE_BOOT" != "/dev/mmcblk0" ]; then
            if [ "$DEVICE_DETECTED" == "true" ]; then
                echo "Auto device is ambigous, detected $DEVICE and /dev/mmcblk0."
                exit 1
            fi
            DEVICE_DETECTED="true"
            DEVICE_MMC="true"
            DEVICE="/dev/mmcblk0"
        fi
    fi
    check_variables_boolean "DEVICE_TRIM" "$DEVICE_TRIM"
    check_variables_boolean "LVM" "$LVM"
    check_variables_equals "LUKS_PASSWORD" "LUKS_PASSWORD_RETYPE" "$LUKS_PASSWORD" "$LUKS_PASSWORD_RETYPE"
    check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 btrfs xfs f2fs reiserfs" "true" "true"
    check_variables_size "BTRFS_SUBVOLUME_ROOT" ${#BTRFS_SUBVOLUME_ROOT[@]} 3
    check_variables_list "BTRFS_SUBVOLUME_ROOT" "${BTRFS_SUBVOLUME_ROOT[2]}" "/" "true" "true"
    if [ -n "$SWAP_SIZE" ]; then
        check_variables_size "BTRFS_SUBVOLUME_SWAP" ${#BTRFS_SUBVOLUME_SWAP[@]} 3
    fi
    for I in "${BTRFS_SUBVOLUMES_MOUNTPOINTS[@]}"; do
        IFS=',' read -ra SUBVOLUME <<< "$I"
        check_variables_size "SUBVOLUME" ${#SUBVOLUME[@]} 3
    done
    check_variables_list "PARTITION_MODE" "$PARTITION_MODE" "auto custom manual" "true" "true"
    check_variables_value "PARTITION_BOOT_NUMBER" "$PARTITION_BOOT_NUMBER"
    check_variables_value "PARTITION_ROOT_NUMBER" "$PARTITION_ROOT_NUMBER"
    check_variables_boolean "CHROOT" "$CHROOT"
}

function warning() {
    echo -e "${BLUE}Welcome to Arch Linux Install Script Recovery${NC}"
    echo ""
    read -r -p "Do you want to continue? [y/N] " yn
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
    print_step "init()"

    init_log_trace "$LOG_TRACE"
    init_log_file "$LOG_FILE" "$RECOVERY_LOG_FILE"
    loadkeys "$KEYS"
}

function facts() {
    print_step "facts()"

    facts_commons

    if echo "$DEVICE" | grep -q "^/dev/sd[a-z]"; then
        DEVICE_SDA="true"
    elif echo "$DEVICE" | grep -q "^/dev/nvme"; then
        DEVICE_NVME="true"
    elif echo "$DEVICE" | grep -q "^/dev/vd[a-z]"; then
        DEVICE_VDA="true"
    elif echo "$DEVICE" | grep -q "^/dev/mmc"; then
        DEVICE_MMC="true"
    fi
}

function prepare() {
    print_step "prepare()"

    prepare_partition
    configure_network
    ask_passwords
}

function prepare_partition() {
    if [ -d "${MNT_DIR}"/boot ]; then
        umount "${MNT_DIR}"/boot
        umount "${MNT_DIR}"
    fi
    if [ -e "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL" ]; then
        umount "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi
    if [ -e "/dev/mapper/$LUKS_DEVICE_NAME" ]; then
        cryptsetup close "$LUKS_DEVICE_NAME"
    fi
    partprobe "$DEVICE"
}

function ask_passwords() {
    if [ "$LUKS_PASSWORD" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -r -sp 'Type LUKS password: ' LUKS_PASSWORD
            echo ""
            read -r -sp 'Retype LUKS password: ' LUKS_PASSWORD_RETYPE
            echo ""
            if [ "$LUKS_PASSWORD" == "$LUKS_PASSWORD_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "LUKS password don't match. Please, type again."
            fi
        done
    fi
}

function partition() {
    print_step "partition()"

    # setup
    partition_setup

    # luks and lvm
    if [ -n "$LUKS_PASSWORD" ]; then
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-file=- open "$PARTITION_ROOT" "$LUKS_DEVICE_NAME"
        sleep 5
    fi

    if [ -n "$LUKS_PASSWORD" ]; then
        DEVICE_ROOT="/dev/mapper/$LUKS_DEVICE_NAME"
    fi
    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT="/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi

    # options
    partition_options

    # mount
    partition_mount
}

function recovery() {
    arch-chroot "${MNT_DIR}"
}

function end() {
    echo ""
    if [ "$CHROOT" == "false" ]; then
        echo -e "${GREEN}Recovery started.${NC}"
    else
        echo -e "${GREEN}Recovery ended.${NC}"
    fi
    echo "You must do an explicit reboot after finalize recovery (exit if in arch-chroot, ./alis-reboot.sh)."
    echo ""
}

function main() {
    init_config
    sanitize_variables
    check_variables
    warning
    init
    facts
    prepare
    partition
    if [ "$CHROOT" == "true" ]; then
        recovery
    fi
    end
}

main
