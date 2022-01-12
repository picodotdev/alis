#!/usr/bin/env bash
set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2022 picodotdev

# Common functions and definitions.

# global variables (no configuration, don't edit)
COMMOMS_LOADED="true"
START_TIMESTAMP=""
END_TIMESTAMP=""
PARTITION_BOOT=""
PARTITION_ROOT=""
PARTITION_BOOT_NUMBER=""
PARTITION_ROOT_NUMBER=""
DEVICE_ROOT=""
DEVICE_LVM=""
LUKS_DEVICE_NAME="cryptroot"
LVM_VOLUME_GROUP="vg"
LVM_VOLUME_LOGICAL="root"
SWAPFILE="/swapfile"
BOOT_DIRECTORY=""
ESP_DIRECTORY=""
UUID_BOOT=""
UUID_ROOT=""
PARTUUID_BOOT=""
PARTUUID_ROOT=""
CMDLINE_LINUX_ROOT=""
CMDLINE_LINUX=""
BTRFS_SUBVOLUME_ROOT=()
BTRFS_SUBVOLUME_SWAP=()
USER_NAME_INSTALL="root"

AUR_PACKAGE="paru-bin"
AUR_COMMAND="paru"

ALIS_CONF_FILE="alis.conf"
ALIS_LOG_FILE="alis.log"
ALIS_ASCIINEMA_FILE="alis.asciinema"
RECOVERY_CONF_FILE="alis-recovery.conf"
RECOVERY_LOG_FILE="alis-recovery.log"
RECOVERY_ASCIINEMA_FILE="alis-recovery.asciinema"
PACKAGES_CONF_FILE="alis-packages.conf"
PACKAGES_LOG_FILE="alis-packages.log"
GLOBALS_FILE="alis-globals.conf"

BIOS_TYPE=""
ASCIINEMA=""
DEVICE_SATA="false"
DEVICE_NVME="false"
DEVICE_MMC="false"
CPU_VENDOR=""
GPU_VENDOR=""
VIRTUALBOX=""
VMWARE=""
SYSTEM_INSTALLATION=""

LOG="false"
USER_NAME="picodotdev"
USER_PASSWORD="ask"
PACKAGES_PIPEWIRE="false"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function sanitize_variable() {
    local VARIABLE="$1"
    local VARIABLE=$(echo "$VARIABLE" | sed "s/![^ ]*//g") # remove disabled
    local VARIABLE=$(echo "$VARIABLE" | sed -r "s/ {2,}/ /g") # remove unnecessary white spaces
    local VARIABLE=$(echo "$VARIABLE" | sed 's/^[[:space:]]*//') # trim leading
    local VARIABLE=$(echo "$VARIABLE" | sed 's/[[:space:]]*$//') # trim trailing
    echo "$VARIABLE"
}

function trim_variable() {
    local VARIABLE="$1"
    local VARIABLE=$(echo "$VARIABLE" | sed 's/^[[:space:]]*//') # trim leading
    local VARIABLE=$(echo "$VARIABLE" | sed 's/[[:space:]]*$//') # trim trailing
    echo "$VARIABLE"
}

function check_variables_value() {
    local NAME="$1"
    local VALUE="$2"
    if [ -z "$VALUE" ]; then
        echo "$NAME environment variable must have a value."
        exit 1
    fi
}

function check_variables_boolean() {
    local NAME="$1"
    local VALUE="$2"
    check_variables_list "$NAME" "$VALUE" "true false" "true" "true"
}

function check_variables_list() {
    local NAME="$1"
    local VALUE="$2"
    local VALUES="$3"
    local REQUIRED="$4"
    local SINGLE="$5"

    if [ "$REQUIRED" == "" -o "$REQUIRED" == "true" ]; then
        check_variables_value "$NAME" "$VALUE"
    fi

    if [[ ("$SINGLE" == "" || "$SINGLE" == "true") && "$VALUE" != "" && "$VALUE" =~ " " ]]; then
        echo "$NAME environment variable value [$VALUE] must be a single value of [$VALUES]."
        exit 1
    fi

    if [ "$VALUE" != "" -a -z "$(echo "$VALUES" | grep -F -w "$VALUE")" ]; then
        echo "$NAME environment variable value [$VALUE] must be in [$VALUES]."
        exit 1
    fi
}

function check_variables_equals() {
    local NAME1="$1"
    local NAME2="$2"
    local VALUE1="$3"
    local VALUE2="$4"
    if [ "$VALUE1" != "$VALUE2" ]; then
        echo "$NAME1 and $NAME2 must be equal [$VALUE1, $VALUE2]."
        exit 1
    fi
}

function check_variables_size() {
    local NAME="$1"
    local SIZE_EXPECT="$2"
    local SIZE="$3"
    if [ "$SIZE_EXPECT" != "$SIZE" ]; then
        echo "$NAME array size [$SIZE] must be [$SIZE_EXPECT]."
        exit 1
    fi
}

function configure_network() {
    if [ -n "$WIFI_INTERFACE" ]; then
        iwctl --passphrase "$WIFI_KEY" station $WIFI_INTERFACE connect "$WIFI_ESSID"
        sleep 10
    fi

    # only one ping -c 1, ping gets stuck if -c 5
    ping -c 1 -i 2 -W 5 -w 30 $PING_HOSTNAME
    if [ $? -ne 0 ]; then
        echo "Network ping check failed. Cannot continue."
        exit 1
    fi
}

function facts_commons() {
    if [ -d /sys/firmware/efi ]; then
        BIOS_TYPE="uefi"
    else
        BIOS_TYPE="bios"
    fi

    if [ -f "$ALIS_ASCIINEMA_FILE" -o -f "$RECOVERY_ASCIINEMA_FILE" ]; then
        ASCIINEMA="true"
    else
        ASCIINEMA="false"
    fi

    if [ -n "$(echo "$DEVICE" | grep "^/dev/[a-z]d[a-z]")" ]; then
        DEVICE_SATA="true"
    elif [ -n "$(echo "$DEVICE" | grep "^/dev/nvme")" ]; then
        DEVICE_NVME="true"
    elif [ -n "$(echo "$DEVICE" | grep "^/dev/mmc")" ]; then
        DEVICE_MMC="true"
    fi

    if [ -n "$(lscpu | grep GenuineIntel)" ]; then
        CPU_VENDOR="intel"
    elif [ -n "$(lscpu | grep AuthenticAMD)" ]; then
        CPU_VENDOR="amd"
    fi

    if [ -n "$(lspci -nn | grep "\[03" | grep -i intel)" ]; then
        GPU_VENDOR="intel"
    elif [ -n "$(lspci -nn | grep "\[03" | grep -i amd)" ]; then
        GPU_VENDOR="amd"
    elif [ -n "$(lspci -nn | grep "\[03" | grep -i nvidia)" ]; then
        GPU_VENDOR="nvidia"
    elif [ -n "$(lspci -nn | grep "\[03" | grep -i vmware)" ]; then
        GPU_VENDOR="vmware"
    fi

    if [ -n "$(systemd-detect-virt | grep -i oracle)" ]; then
        VIRTUALBOX="true"
    fi

    if [ -n "$(systemd-detect-virt | grep -i vmware)" ]; then
        VMWARE="true"
    fi

    case "$AUR_PACKAGE" in
        "aurman" )
            AUR_COMMAND="aurman"
            ;;
        "yay" )
            AUR_COMMAND="yay"
            ;;
        "paru" )
            AUR_COMMAND="paru"
            ;;
        "yay-bin" )
            AUR_COMMAND="yay"
            ;;
        "paru-bin" | *)
            AUR_COMMAND="paru"
            ;;
    esac

    USER_NAME_INSTALL="$(whoami)"
    if [ "$USER_NAME_INSTALL" == "root" ]; then
        SYSTEM_INSTALLATION="true"
    else
        SYSTEM_INSTALLATION="false"
    fi
}

function init_log() {
    local ENABLE="$1"
    local FILE="$2"
    if [ "$ENABLE" == "true" ]; then
        exec > >(tee -a $FILE)
        exec 2> >(tee -a $FILE >&2)
    fi
    set -o xtrace
}

function pacman_uninstall() {
    local ERROR="true"
    set +e
    IFS=' ' local PACKAGES=($1)
    local PACKAGES_UNINSTALL=()
    for PACKAGE in "${PACKAGES[@]}"
    do
        execute_user "pacman -Qi $PACKAGE > /dev/null 2>&1"
        local PACKAGE_INSTALLED=$?
        if [ $PACKAGE_INSTALLED == 0 ]; then
            local PACKAGES_UNINSTALL+=("$PACKAGE")
        fi
    done
    if [ -z "${PACKAGES_UNINSTALL[@]}" ]; then
        return
    fi
    local COMMAND="pacman -Rdd --noconfirm ${PACKAGES_UNINSTALL[@]}"
    execute_sudo "$COMMAND"
    if [ $? == 0 ]; then
        local ERROR="false"
    fi
    set -e
    if [ "$ERROR" == "true" ]; then
        exit 1
    fi
}

function pacman_install() {
    local ERROR="true"
    set +e
    IFS=' ' local PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_sudo "$COMMAND"
        if [ $? == 0 ]; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit 1
    fi
}

function aur_install() {
    local ERROR="true"
    set +e
    which "$AUR_COMMAND"
    if [ "$AUR_COMMAND" != "0" ]; then
        aur_command_install "$USER_NAME" "$AUR_PACKAGE"
    fi
    IFS=' ' local PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        local COMMAND="$AUR_COMMAND -Syu --noconfirm --needed ${PACKAGES[@]}"
        execute_aur "$COMMAND"
        if [ $? == 0 ]; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function aur_command_install() {
    pacman_install "git"
    local USER_NAME="$1"
    local COMMAND="$2"
    execute_aur "rm -rf /home/$USER_NAME/.alis/aur/$COMMAND && mkdir -p /home/$USER_NAME/.alis/aur && cd /home/$USER_NAME/.alis/aur && git clone https://aur.archlinux.org/$COMMAND.git && (cd $COMMAND && makepkg -si --noconfirm) && rm -rf /home/$USER_NAME/.alis/aur/$COMMAND"
}

function systemd_units() {
    IFS=' ' local UNITS=($SYSTEMD_UNITS)
    for U in ${UNITS[@]}; do
        local ACTION=""
        local UNIT=${U}
        if [[ $UNIT == -* ]]; then
            local ACTION="disable"
            local UNIT=$(echo $UNIT | sed "s/^-//g")
        elif [[ $UNIT == +* ]]; then
            local ACTION="enable"
            local UNIT=$(echo $UNIT | sed "s/^+//g")
        elif [[ $UNIT =~ ^[a-zA-Z0-9]+ ]]; then
            local ACTION="enable"
            local UNIT=$UNIT
        fi

        if [ -n "$ACTION" ]; then
            execute_sudo "systemctl $ACTION $UNIT"
        fi
    done
}

function execute_flatpak() {
    local COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        bash -c "$COMMAND"
    fi
}

function execute_aur() {
    local COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
        arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
        arch-chroot /mnt sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers
    else
        bash -c "$COMMAND"
    fi
}

function execute_sudo() {
    local COMMAND="$1"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "$COMMAND"
    else
        sudo bash -c "$COMMAND"
    fi
}

function execute_user() {
    local USER_NAME="$1"
    local COMMAND="$2"
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        arch-chroot /mnt bash -c "su $USER_NAME -s /usr/bin/bash -c \"$COMMAND\""
    else
        bash -c "$COMMAND"
    fi
}

function do_reboot() {
    umount -R /mnt/boot
    umount -R /mnt
    reboot
}

function print_step() {
    STEP="$1"
    echo ""
    echo -e "${LIGHT_BLUE}# ${STEP} step${NC}"
    echo ""
}

function execute_step() {
    STEP="$1"
    STEPS="$2"
    if [[ " $STEPS " =~ " $STEP " ]]; then
        eval $STEP
        save_globals
    else
        echo "Skipping $STEP"
    fi
}

function save_globals() {
    cat <<EOT > $GLOBALS_FILE
ASCIINEMA="$ASCIINEMA"
BIOS_TYPE="$BIOS_TYPE"
PARTITION_BOOT="$PARTITION_BOOT"
PARTITION_ROOT="$PARTITION_ROOT"
PARTITION_BOOT_NUMBER="$PARTITION_BOOT_NUMBER"
PARTITION_ROOT_NUMBER="$PARTITION_ROOT_NUMBER"
DEVICE_ROOT="$DEVICE_ROOT"
DEVICE_LVM="$DEVICE_LVM"
LUKS_DEVICE_NAME="$LUKS_DEVICE_NAME"
LVM_VOLUME_GROUP="$LVM_VOLUME_GROUP"
LVM_VOLUME_LOGICAL="$LVM_VOLUME_LOGICAL"
SWAPFILE="$SWAPFILE"
BOOT_DIRECTORY="$BOOT_DIRECTORY"
ESP_DIRECTORY="$ESP_DIRECTORY"
UUID_BOOT="$UUID_BOOT"
UUID_ROOT="$UUID_ROOT"
PARTUUID_BOOT="$PARTUUID_BOOT"
PARTUUID_ROOT="$PARTUUID_ROOT"
DEVICE_SATA="$DEVICE_SATA"
DEVICE_NVME="$DEVICE_NVME"
DEVICE_MMC="$DEVICE_MMC"
CPU_VENDOR="$CPU_VENDOR"
VIRTUALBOX="$VIRTUALBOX"
VMWARE="$VMWARE"
CMDLINE_LINUX_ROOT="$CMDLINE_LINUX_ROOT"
CMDLINE_LINUX="$CMDLINE_LINUX"
BTRFS_SUBVOLUME_ROOT=("${BTRFS_SUBVOLUME_ROOT[@]}")
BTRFS_SUBVOLUME_SWAP=("${BTRFS_SUBVOLUME_SWAP[@]}")
EOT
}

function partition_setup() {
    # setup
    if [ "$PARTITION_MODE" == "auto" ]; then
        PARTITION_PARTED_FILE_SYSTEM_TYPE="$FILE_SYSTEM_TYPE"
        if [ "$PARTITION_PARTED_FILE_SYSTEM_TYPE" == "f2fs" ]; then
            PARTITION_PARTED_FILE_SYSTEM_TYPE=""
        fi
        PARTITION_PARTED_UEFI="mklabel gpt mkpart ESP fat32 1MiB 512MiB mkpart root $PARTITION_PARTED_FILE_SYSTEM_TYPE 512MiB 100% set 1 esp on"
        PARTITION_PARTED_BIOS="mklabel msdos mkpart primary ext4 4MiB 512MiB mkpart primary $PARTITION_PARTED_FILE_SYSTEM_TYPE 512MiB 100% set 1 boot on"

        if [ "$BIOS_TYPE" == "uefi" ]; then
            if [ "$DEVICE_SATA" == "true" ]; then
                PARTITION_BOOT="${DEVICE}1"
                PARTITION_ROOT="${DEVICE}2"
                DEVICE_ROOT="${DEVICE}2"
            fi

            if [ "$DEVICE_NVME" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi

            if [ "$DEVICE_MMC" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi
        fi

        if [ "$BIOS_TYPE" == "bios" ]; then
            if [ "$DEVICE_SATA" == "true" ]; then
                PARTITION_BOOT="${DEVICE}1"
                PARTITION_ROOT="${DEVICE}2"
                DEVICE_ROOT="${DEVICE}2"
            fi

            if [ "$DEVICE_NVME" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi

            if [ "$DEVICE_MMC" == "true" ]; then
                PARTITION_BOOT="${DEVICE}p1"
                PARTITION_ROOT="${DEVICE}p2"
                DEVICE_ROOT="${DEVICE}p2"
            fi
        fi
    elif [ "$PARTITION_MODE" == "custom" ]; then
        PARTITION_PARTED_UEFI="$PARTITION_CUSTOM_PARTED_UEFI"
        PARTITION_PARTED_BIOS="$PARTITION_CUSTOM_PARTED_BIOS"
    fi

    if [ "$PARTITION_MODE" == "custom" -o "$PARTITION_MODE" == "manual" ]; then
        PARTITION_BOOT="$PARTITION_CUSTOMMANUAL_BOOT"
        PARTITION_ROOT="$PARTITION_CUSTOMMANUAL_ROOT"
        DEVICE_ROOT="${PARTITION_ROOT}"
    fi

    PARTITION_BOOT_NUMBER="$PARTITION_BOOT"
    PARTITION_ROOT_NUMBER="$PARTITION_ROOT"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/sda/}"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/nvme0n1p/}"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/vda/}"
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/mmcblk0p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/sda/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/nvme0n1p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/vda/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/mmcblk0p/}"
}

function partition_options() {
    PARTITION_OPTIONS_BOOT="defaults"
    PARTITION_OPTIONS="defaults"

    if [ "$DEVICE_TRIM" == "true" ]; then
        PARTITION_OPTIONS_BOOT="$PARTITION_OPTIONS_BOOT,noatime"
        PARTITION_OPTIONS="$PARTITION_OPTIONS,noatime"
        if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
            PARTITION_OPTIONS="$PARTITION_OPTIONS,nodiscard"
        fi
    fi
}

function partition_mount() {
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        # mount subvolumes
        mount -o "subvol=${BTRFS_SUBVOLUME_ROOT[1]},$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt
        mkdir -p /mnt/boot
        mount -o "$PARTITION_OPTIONS_BOOT" "$PARTITION_BOOT" /mnt/boot
        for I in "${BTRFS_SUBVOLUMES_MOUNTPOINTS[@]}"; do
            IFS=',' SUBVOLUME=($I)
            if [ ${SUBVOLUME[0]} == "root" ]; then
                continue
            fi
            if [ ${SUBVOLUME[0]} == "swap" -a -z "$SWAP_SIZE" ]; then
                continue
            fi
            if [ ${SUBVOLUME[0]} == "swap" ]; then
                mkdir -p -m 0755 "/mnt${SUBVOLUME[2]}"
            else
                mkdir -p "/mnt${SUBVOLUME[2]}"
            fi
            mount -o "subvol=${SUBVOLUME[1]},$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" "/mnt${SUBVOLUME[2]}"
        done
    else
        mount -o "$PARTITION_OPTIONS" "$DEVICE_ROOT" /mnt

        mkdir -p /mnt/boot
        mount -o "$PARTITION_OPTIONS_BOOT" "$PARTITION_BOOT" /mnt/boot
    fi
}