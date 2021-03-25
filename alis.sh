#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2021 picodotdev

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

# Usage:
# # loadkeys es
# # iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
# # curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash -s -- -u [github user], or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# # vim alis.conf
# # ./alis.sh

# global variables (no configuration, don't edit)
ASCIINEMA=""
BIOS_TYPE=""
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
#PARTITION_BOOT_NUMBER=0
UUID_BOOT=""
UUID_ROOT=""
PARTUUID_BOOT=""
PARTUUID_ROOT=""
DEVICE_SATA=""
DEVICE_NVME=""
DEVICE_MMC=""
CPU_VENDOR=""
VIRTUALBOX=""
CMDLINE_LINUX_ROOT=""
CMDLINE_LINUX=""

CONF_FILE="alis.conf"
GLOBALS_FILE="alis-globals.conf"
LOG_FILE="alis.log"
ASCIINEMA_FILE="alis.asciinema"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source "$CONF_FILE"
}

function sanitize_variables() {
    DEVICE=$(sanitize_variable "$DEVICE")
    PARTITION_MODE=$(sanitize_variable "$PARTITION_MODE")
    PARTITION_CUSTOM_PARTED_UEFI=$(sanitize_variable "$PARTITION_CUSTOM_PARTED_UEFI")
    PARTITION_CUSTOM_PARTED_BIOS=$(sanitize_variable "$PARTITION_CUSTOM_PARTED_BIOS")
    PARTITION_CUSTOMMANUAL_BOOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_BOOT")
    PARTITION_CUSTOMMANUAL_ROOT=$(sanitize_variable "$PARTITION_CUSTOMMANUAL_ROOT")
    FILE_SYSTEM_TYPE=$(sanitize_variable "$FILE_SYSTEM_TYPE")
    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    KERNELS=$(sanitize_variable "$KERNELS")
    KERNELS_COMPRESSION=$(sanitize_variable "$KERNELS_COMPRESSION")
    SYSTEMD_HOMED_STORAGE=$(sanitize_variable "$SYSTEMD_HOMED_STORAGE")
    BOOTLOADER=$(sanitize_variable "$BOOTLOADER")
    CUSTOM_SHELL=$(sanitize_variable "$CUSTOM_SHELL")
    DESKTOP_ENVIRONMENT=$(sanitize_variable "$DESKTOP_ENVIRONMENT")
    DISPLAY_DRIVER=$(sanitize_variable "$DISPLAY_DRIVER")
    DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL=$(sanitize_variable "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL")
    SYSTEMD_UNITS=$(sanitize_variable "$SYSTEMD_UNITS")
}

function sanitize_variable() {
    VARIABLE=$1
    VARIABLE=$(echo $VARIABLE | sed "s/![^ ]*//g") # remove disabled
    VARIABLE=$(echo $VARIABLE | sed "s/ {2,}/ /g") # remove unnecessary white spaces
    VARIABLE=$(echo $VARIABLE | sed 's/^[[:space:]]*//') # trim leading
    VARIABLE=$(echo $VARIABLE | sed 's/[[:space:]]*$//') # trim trailing
    echo "$VARIABLE"
}

function check_variables() {
    check_variables_value "KEYS" "$KEYS"
    check_variables_boolean "LOG" "$LOG"
    check_variables_value "DEVICE" "$DEVICE"
    check_variables_boolean "DEVICE_TRIM" "$DEVICE_TRIM"
    check_variables_boolean "LVM" "$LVM"
    check_variables_equals "LUKS_PASSWORD" "LUKS_PASSWORD_RETYPE" "$LUKS_PASSWORD" "$LUKS_PASSWORD_RETYPE"
    check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 btrfs xfs f2fs reiserfs"
    check_variables_list "PARTITION_MODE" "$PARTITION_MODE" "auto custom manual" "true"
    if [ "$PARTITION_MODE" == "custom" ]; then
        check_variables_value "PARTITION_CUSTOM_PARTED_UEFI" "$PARTITION_CUSTOM_PARTED_UEFI"
        check_variables_value "PARTITION_CUSTOM_PARTED_BIOS" "$PARTITION_CUSTOM_PARTED_BIOS"
    fi
    if [ "$PARTITION_MODE" == "custom" -o "$PARTITION_MODE" == "manual" ]; then
        check_variables_value "PARTITION_CUSTOMMANUAL_BOOT" "$PARTITION_CUSTOMMANUAL_BOOT"
        check_variables_value "PARTITION_CUSTOMMANUAL_ROOT" "$PARTITION_CUSTOMMANUAL_ROOT"
    fi
    if [ "$LVM" == "true" ]; then
        check_variables_list "PARTITION_MODE" "$PARTITION_MODE" "auto" "true"
    fi
    check_variables_equals "WIFI_KEY" "WIFI_KEY_RETYPE" "$WIFI_KEY" "$WIFI_KEY_RETYPE"
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_value "PACMAN_MIRROR" "$PACMAN_MIRROR"
    check_variables_list "KERNELS" "$KERNELS" "linux-lts linux-lts-headers linux-hardened linux-hardened-headers linux-zen linux-zen-headers" "false"
    check_variables_list "KERNELS_COMPRESSION" "$KERNELS_COMPRESSION" "gzip bzip2 lzma xz lzop lz4 zstd" "false"
    check_variables_list "DISPLAY_DRIVER" "$DISPLAY_DRIVER" "intel amdgpu ati nvidia nvidia-lts nvidia-dkms nvidia-390xx nvidia-390xx-lts nvidia-390xx-dkms nouveau" "false"
    check_variables_boolean "KMS" "$KMS"
    check_variables_boolean "FASTBOOT" "$FASTBOOT"
    check_variables_boolean "FRAMEBUFFER_COMPRESSION" "$FRAMEBUFFER_COMPRESSION"
    check_variables_boolean "DISPLAY_DRIVER_DDX" "$DISPLAY_DRIVER_DDX"
    check_variables_boolean "DISPLAY_DRIVER_HARDWARE_ACCELERATION" "$DISPLAY_DRIVER_HARDWARE_ACCELERATION"
    check_variables_list "DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" "intel-media-driver libva-intel-driver" "false"
    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_boolean "REFLECTOR" "$REFLECTOR"
    check_variables_value "PACMAN_MIRROR" "$PACMAN_MIRROR"
    check_variables_value "LOCALES" "$LOCALES"
    check_variables_value "LOCALE_CONF" "$LOCALE_CONF"
    check_variables_value "LANG" "$LANG"
    check_variables_value "KEYMAP" "$KEYMAP"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_equals "ROOT_PASSWORD" "ROOT_PASSWORD_RETYPE" "$ROOT_PASSWORD" "$ROOT_PASSWORD_RETYPE"
    check_variables_equals "USER_PASSWORD" "USER_PASSWORD_RETYPE" "$USER_PASSWORD" "$USER_PASSWORD_RETYPE"
    check_variables_boolean "SYSTEMD_HOMED" "$SYSTEMD_HOMED"
    if [ "$SYSTEMD_HOMED" == "true" ]; then
        check_variables_list "SYSTEMD_HOMED_STORAGE" "$SYSTEMD_HOMED_STORAGE" "directory fscrypt luks cifs subvolume" "true"

        if [ "$SYSTEMD_HOMED_STORAGE" == "fscrypt" ]; then
            check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 f2fs" "true"
        fi
        if [ "$SYSTEMD_HOMED_STORAGE" == "cifs" ]; then
            check_variables_value "SYSTEMD_HOMED_CIFS_DOMAIN" "$SYSTEMD_HOMED_CIFS_DOMAIN"
            check_variables_value "SYSTEMD_HOMED_CIFS_SERVICE" "$SYSTEMD_HOMED_CIFS_SERVICE"
        fi
    fi
    check_variables_value "HOOKS" "$HOOKS"
    check_variables_list "BOOTLOADER" "$BOOTLOADER" "grub refind systemd"
    check_variables_list "CUSTOM_SHELL" "$CUSTOM_SHELL" "bash zsh dash fish"
    check_variables_list "DESKTOP_ENVIRONMENT" "$DESKTOP_ENVIRONMENT" "gnome kde xfce mate cinnamon lxde i3-wm i3-gaps" "false"
    check_variables_boolean "PACKAGES_MULTILIB" "$PACKAGES_MULTILIB"
    check_variables_boolean "PACKAGES_INSTALL" "$PACKAGES_INSTALL"
    check_variables_boolean "VAGRANT" "$VAGRANT"
    check_variables_boolean "REBOOT" "$REBOOT"
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

function check_variables_equals() {
    NAME1=$1
    NAME2=$2
    VALUE1=$3
    VALUE2=$4
    if [ "$VALUE1" != "$VALUE2" ]; then
        echo "$NAME1 and $NAME2 must be equal [$VALUE1, $VALUE2]."
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
    echo -e "${LIGHT_BLUE}Welcome to Arch Linux Install Script${NC}"
    echo ""
    echo -e "${RED}Warning"'!'"${NC}"
    echo -e "${RED}This script deletes all partitions of the persistent${NC}"
    echo -e "${RED}storage and continuing all your data in it will be lost.${NC}"
    echo ""
    read -p "Do you want to continue? [y/N] " yn
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

    init_log
    loadkeys $KEYS
}

function init_log() {
    if [ "$LOG" == "true" ]; then
        exec > >(tee -a $LOG_FILE)
        exec 2> >(tee -a $LOG_FILE >&2)
    fi
    set -o xtrace
}

function facts() {
    print_step "facts()"

    if [ -d /sys/firmware/efi ]; then
        BIOS_TYPE="uefi"
    else
        BIOS_TYPE="bios"
    fi

    if [ -f "$ASCIINEMA_FILE" ]; then
        ASCIINEMA="true"
    else
        ASCIINEMA="false"
    fi

    DEVICE_SATA="false"
    DEVICE_NVME="false"
    DEVICE_MMC="false"
    if [ -n "$(echo $DEVICE | grep "^/dev/[a-z]d[a-z]")" ]; then
        DEVICE_SATA="true"
    elif [ -n "$(echo $DEVICE | grep "^/dev/nvme")" ]; then
        DEVICE_NVME="true"
    elif [ -n "$(echo $DEVICE | grep "^/dev/mmc")" ]; then
        DEVICE_MMC="true"
    fi

    if [ -n "$(lscpu | grep GenuineIntel)" ]; then
        CPU_VENDOR="intel"
    elif [ -n "$(lscpu | grep AuthenticAMD)" ]; then
        CPU_VENDOR="amd"
    fi

    if [ -n "$(lspci | grep -i virtualbox)" ]; then
        VIRTUALBOX="true"
    fi
}

function checks() {
    print_step "checks()"

    check_facts
}

function check_facts() {
    if [ "$BIOS_TYPE" == "bios" ]; then
        check_variables_list "BOOTLOADER" "$BOOTLOADER" "grub"
    fi
}

function prepare() {
    print_step "prepare()"

    configure_reflector
    configure_time
    prepare_partition
    ask_passwords
    configure_network
}

function configure_reflector() {
    if [ "$REFLECTOR" == "false" ]; then
        systemctl stop reflector.service
    fi
}

function configure_time() {
    timedatectl set-ntp true
}

function prepare_partition() {
    if [ -d /mnt/boot ]; then
        umount /mnt/boot
        umount /mnt
    fi
    if [ -e "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL" ]; then
        umount "/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi
    if [ -e "/dev/mapper/$LUKS_DEVICE_NAME" ]; then
        cryptsetup close $LUKS_DEVICE_NAME
    fi
}

function ask_passwords() {
    if [ "$LUKS_PASSWORD" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -sp 'Type LUKS password: ' LUKS_PASSWORD
            echo ""
            read -sp 'Retype LUKS password: ' LUKS_PASSWORD_RETYPE
            echo ""
            if [ "$LUKS_PASSWORD" == "$LUKS_PASSWORD_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "LUKS password don't match. Please, type again."
            fi
        done
    fi

    if [ -n "$WIFI_INTERFACE" -a "$WIFI_KEY" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -sp 'Type WIFI key: ' WIFI_KEY
            echo ""
            read -sp 'Retype WIFI key: ' WIFI_KEY_RETYPE
            echo ""
            if [ "$WIFI_KEY" == "$WIFI_KEY_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "WIFI key don't match. Please, type again."
            fi
        done
    fi

    if [ "$ROOT_PASSWORD" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -sp 'Type root password: ' ROOT_PASSWORD
            echo ""
            read -sp 'Retype root password: ' ROOT_PASSWORD_RETYPE
            echo ""
            if [ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "Root password don't match. Please, type again."
            fi
        done
    fi

    if [ "$USER_PASSWORD" == "ask" ]; then
        PASSWORD_TYPED="false"
        while [ "$PASSWORD_TYPED" != "true" ]; do
            read -sp 'Type user password: ' USER_PASSWORD
            echo ""
            read -sp 'Retype user password: ' USER_PASSWORD_RETYPE
            echo ""
            if [ "$USER_PASSWORD" == "$USER_PASSWORD_RETYPE" ]; then
                PASSWORD_TYPED="true"
            else
                echo "User password don't match. Please, type again."
            fi
        done
    fi

    for I in ${!ADDITIONAL_USERS[@]}; do
        VALUE=${ADDITIONAL_USERS[${I}]}
        IFS='=' S=($VALUE)
        USER=${S[0]}
        PASSWORD=${S[1]}
        PASSWORD_RETYPE=""

        if [ "$PASSWORD" == "ask" ]; then
            PASSWORD_TYPED="false"
            while [ "$PASSWORD_TYPED" != "true" ]; do
                read -sp "Type user ($USER) password: " PASSWORD
                echo ""
                read -sp "Retype user ($USER) password: " PASSWORD_RETYPE
                echo ""
                if [ "$PASSWORD" == "$PASSWORD_RETYPE" ]; then
                    PASSWORD_TYPED="true"
                    ADDITIONAL_USERS[${I}]="${USER}=${PASSWORD}"
                else
                    echo "User ($USER) password don't match. Please, type again."
                fi
            done
        fi
    done
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
        exit
    fi
}

function partition() {
    print_step "partition()"

    partprobe $DEVICE

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
    PARTITION_BOOT_NUMBER="${PARTITION_BOOT_NUMBER//\/dev\/mmcblk0p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/sda/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/nvme0n1p/}"
    PARTITION_ROOT_NUMBER="${PARTITION_ROOT_NUMBER//\/dev\/mmcblk0p/}"

    # partition
    if [ "$PARTITION_MODE" == "auto" ]; then
        sgdisk --zap-all $DEVICE
        wipefs -a -f $DEVICE
        partprobe $DEVICE
    fi

    if [ "$PARTITION_MODE" == "auto" -o "$PARTITION_MODE" == "custom" ]; then
        if [ "$BIOS_TYPE" == "uefi" ]; then
            parted -s $DEVICE $PARTITION_PARTED_UEFI
            if [ -n "$LUKS_PASSWORD" ]; then
                sgdisk -t=$PARTITION_ROOT_NUMBER:8309 $DEVICE
            elif [ "$LVM" == "true" ]; then
                sgdisk -t=$PARTITION_ROOT_NUMBER:8e00 $DEVICE
            fi
        fi

        if [ "$BIOS_TYPE" == "bios" ]; then
            parted -s $DEVICE $PARTITION_PARTED_BIOS
        fi

        partprobe $DEVICE
    fi

    # luks and lvm
    if [ -n "$LUKS_PASSWORD" ]; then
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 $PARTITION_ROOT
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-file=- open $PARTITION_ROOT $LUKS_DEVICE_NAME
        sleep 5
    fi

    if [ "$LVM" == "true" ]; then
        if [ -n "$LUKS_PASSWORD" ]; then
            DEVICE_LVM="/dev/mapper/$LUKS_DEVICE_NAME"
        else
            DEVICE_LVM="$DEVICE_ROOT"
        fi

        pvcreate $DEVICE_LVM
        vgcreate $LVM_VOLUME_GROUP $DEVICE_LVM
        lvcreate -l 100%FREE -n $LVM_VOLUME_LOGICAL $LVM_VOLUME_GROUP
    fi

    if [ -n "$LUKS_PASSWORD" ]; then
        DEVICE_ROOT="/dev/mapper/$LUKS_DEVICE_NAME"
    fi
    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT="/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi

    # format
    wipefs -a -f $PARTITION_BOOT || true
    wipefs -a -f $DEVICE_ROOT || true

    if [ "$BIOS_TYPE" == "uefi" ]; then
        mkfs.fat -n ESP -F32 $PARTITION_BOOT
    fi
    if [ "$BIOS_TYPE" == "bios" ]; then
        mkfs.ext4 -L boot $PARTITION_BOOT
    fi
    if [ "$FILE_SYSTEM_TYPE" == "f2fs" -o "$FILE_SYSTEM_TYPE" == "reiserfs" ]; then
        mkfs."$FILE_SYSTEM_TYPE" -l root $DEVICE_ROOT
    else
        mkfs."$FILE_SYSTEM_TYPE" -L root $DEVICE_ROOT
    fi

    # options
    PARTITION_OPTIONS_BOOT="defaults"
    PARTITION_OPTIONS_ROOT="defaults"

    if [ "$DEVICE_TRIM" == "true" ]; then
        PARTITION_OPTIONS_BOOT="$PARTITION_OPTIONS_BOOT,noatime"
        PARTITION_OPTIONS_ROOT="$PARTITION_OPTIONS_ROOT,noatime"
        if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
            PARTITION_OPTIONS_ROOT="$PARTITION_OPTIONS_ROOT,nodiscard"
        fi
    fi

    # mount
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        mount -o "$PARTITION_OPTIONS" "$DEVICE_ROOT" /mnt
        btrfs subvolume create /mnt/root
        btrfs subvolume create /mnt/home
        btrfs subvolume create /mnt/var
        btrfs subvolume create /mnt/snapshots
        umount /mnt

        mount -o "subvol=root,$PARTITION_OPTIONS,compress=zstd" "$DEVICE_ROOT" /mnt

        mkdir /mnt/{boot,home,var,snapshots}
        mount -o "$PARTITION_OPTIONS_BOOT" "$PARTITION_BOOT" /mnt/boot
        mount -o "subvol=home,$PARTITION_OPTIONS_ROOT,compress=zstd" "$DEVICE_ROOT" /mnt/home
        mount -o "subvol=var,$PARTITION_OPTIONS_ROOT,compress=zstd" "$DEVICE_ROOT" /mnt/var
        mount -o "subvol=snapshots,$PARTITION_OPTIONS_ROOT,compress=zstd" "$DEVICE_ROOT" /mnt/snapshots
    else
        mount -o "$PARTITION_OPTIONS_ROOT" "$DEVICE_ROOT" /mnt

        mkdir /mnt/boot
        mount -o "$PARTITION_OPTIONS_BOOT" "$PARTITION_BOOT" /mnt/boot
    fi

    # swap
    if [ -n "$SWAP_SIZE" ]; then
        if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
            truncate -s 0 /mnt$SWAPFILE
            chattr +C /mnt$SWAPFILE
            btrfs property set /mnt$SWAPFILE compression none
        fi

        dd if=/dev/zero of=/mnt$SWAPFILE bs=1M count=$SWAP_SIZE status=progress
        chmod 600 /mnt$SWAPFILE
        mkswap /mnt$SWAPFILE
    fi

    # set variables
    BOOT_DIRECTORY=/boot
    ESP_DIRECTORY=/boot
    UUID_BOOT=$(blkid -s UUID -o value $PARTITION_BOOT)
    UUID_ROOT=$(blkid -s UUID -o value $PARTITION_ROOT)
    PARTUUID_BOOT=$(blkid -s PARTUUID -o value $PARTITION_BOOT)
    PARTUUID_ROOT=$(blkid -s PARTUUID -o value $PARTITION_ROOT)
}

function install() {
    print_step "install()"

    if [ -n "$PACMAN_MIRROR" ]; then
        echo "Server = $PACMAN_MIRROR" > /etc/pacman.d/mirrorlist
    fi
    if [ "$REFLECTOR" == "true" ]; then
        COUNTRIES=()
        for COUNTRY in "${REFLECTOR_COUNTRIES[@]}"; do
            COUNTRIES+=(--country "${COUNTRY}")
        done
        pacman -Sy --noconfirm reflector
        reflector "${COUNTRIES[@]}" --latest 25 --age 24 --protocol https --completion-percent 100 --sort rate --save /etc/pacman.d/mirrorlist
    fi

    sed -i 's/#Color/Color/' /etc/pacman.conf
    sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

    pacstrap /mnt base base-devel linux linux-firmware

    sed -i 's/#Color/Color/' /mnt/etc/pacman.conf
    sed -i 's/#TotalDownload/TotalDownload/' /mnt/etc/pacman.conf

    if [ "$PACKAGES_MULTILIB" == "true" ]; then
        echo "" >> /mnt/etc/pacman.conf
        echo "[multilib]" >> /mnt/etc/pacman.conf
        echo "Include = /etc/pacman.d/mirrorlist" >> /mnt/etc/pacman.conf
        echo "" >> /mnt/etc/pacman.conf
    fi
}

function configuration() {
    print_step "configuration()"

    genfstab -U /mnt >> /mnt/etc/fstab

    if [ -n "$SWAP_SIZE" ]; then
        echo "# swap" >> /mnt/etc/fstab
        echo "$SWAPFILE none swap defaults 0 0" >> /mnt/etc/fstab
        echo "" >> /mnt/etc/fstab
    fi

    if [ "$DEVICE_TRIM" == "true" ]; then
        if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
            sed -i 's/relatime/noatime,nodiscard/' /mnt/etc/fstab
        else
            sed -i 's/relatime/noatime/' /mnt/etc/fstab
        fi
        arch-chroot /mnt systemctl enable fstrim.timer
    fi

    arch-chroot /mnt ln -s -f $TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    for LOCALE in "${LOCALES[@]}"; do
        sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
        sed -i "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
    done
    for VARIABLE in "${LOCALE_CONF[@]}"; do
        #localectl set-locale "$VARIABLE"
        echo -e "$VARIABLE" >> /mnt/etc/locale.conf
    done
    locale-gen
    arch-chroot /mnt locale-gen
    echo -e "$KEYMAP\n$FONT\n$FONT_MAP" > /mnt/etc/vconsole.conf
    echo $HOSTNAME > /mnt/etc/hostname

    OPTIONS=""
    if [ -n "$KEYLAYOUT" ]; then
        OPTIONS="$OPTIONS"$'\n'"    Option \"XkbLayout\" \"$KEYLAYOUT\""
    fi
    if [ -n "$KEYMODEL" ]; then
        OPTIONS="$OPTIONS"$'\n'"    Option \"XkbModel\" \"$KEYMODEL\""
    fi
    if [ -n "$KEYVARIANT" ]; then
        OPTIONS="$OPTIONS"$'\n'"    Option \"XkbVariant\" \"$KEYVARIANT\""
    fi
    if [ -n "$KEYOPTIONS" ]; then
        OPTIONS="$OPTIONS"$'\n'"    Option \"XkbOptions\" \"$KEYOPTIONS\""
    fi

    arch-chroot /mnt mkdir -p "/etc/X11/xorg.conf.d/"
    cat <<EOT > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
# Written by systemd-localed(8), read by systemd-localed and Xorg. It's
# probably wise not to edit this file manually. Use localectl(1) to
# instruct systemd-localed to update it.
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    $OPTIONS
EndSection
EOT

    if [ -n "$SWAP_SIZE" ]; then
        echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-sysctl.conf
    fi

    printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | arch-chroot /mnt passwd
}

function mkinitcpio_configuration() {
    print_step "mkinitcpio_configuration()"

    if [ "$KMS" == "true" ]; then
        MODULES=""
        case "$DISPLAY_DRIVER" in
            "intel" )
                MODULES="i915"
                ;;
            "nvidia" | "nvidia-lts"  | "nvidia-dkms" | "nvidia-390xx" | "nvidia-390xx-lts" | "nvidia-390xx-dkms" )
                MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
                ;;
            "amdgpu" )
                MODULES="amdgpu"
                ;;
            "ati" )
                MODULES="radeon"
                ;;
            "nouveau" )
                MODULES="nouveau"
                ;;
        esac
        arch-chroot /mnt sed -i "s/^MODULES=()/MODULES=($MODULES)/" /etc/mkinitcpio.conf
    fi
    if [ "$DISPLAY_DRIVER" == "intel" ]; then
        OPTIONS=""
        if [ "$FASTBOOT" == "true" ]; then
            OPTIONS="$OPTIONS fastboot=1"
        fi
        if [ "$FRAMEBUFFER_COMPRESSION" == "true" ]; then
            OPTIONS="$OPTIONS enable_fbc=1"
        fi
        if [ -n "$OPTIONS"]; then
            echo "options i915 $OPTIONS" > /mnt/etc/modprobe.d/i915.conf
        fi
    fi

    if [ "$LVM" == "true" ]; then
        pacman_install "lvm2"
    fi
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        pacman_install "btrfs-progs"
    fi
    if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
        pacman_install "f2fs-tools"
    fi
    if [ "$FILE_SYSTEM_TYPE" == "reiserfs" ]; then
        pacman_install "reiserfsprogs"
    fi

    if [ "$BOOTLOADER" == "systemd" ]; then
        HOOKS=$(echo $HOOKS | sed 's/!systemd/systemd/')
        HOOKS=$(echo $HOOKS | sed 's/!sd-vconsole/sd-vconsole/')
        if [ "$LVM" == "true" ]; then
            HOOKS=$(echo $HOOKS | sed 's/!sd-lvm2/sd-lvm2/')
        fi
        if [ -n "$LUKS_PASSWORD" ]; then
            HOOKS=$(echo $HOOKS | sed 's/!sd-encrypt/sd-encrypt/')
        fi
    else
        HOOKS=$(echo $HOOKS | sed 's/!udev/udev/')
        HOOKS=$(echo $HOOKS | sed 's/!usr/usr/')
        HOOKS=$(echo $HOOKS | sed 's/!keymap/keymap/')
        HOOKS=$(echo $HOOKS | sed 's/!consolefont/consolefont/')
        if [ "$LVM" == "true" ]; then
            HOOKS=$(echo $HOOKS | sed 's/!lvm2/lvm2/')
        fi
        if [ -n "$LUKS_PASSWORD" ]; then
            HOOKS=$(echo $HOOKS | sed 's/!encrypt/encrypt/')
        fi
    fi
    HOOKS=$(sanitize_variable "$HOOKS")
    arch-chroot /mnt sed -i "s/^HOOKS=(.*)$/HOOKS=($HOOKS)/" /etc/mkinitcpio.conf

    if [ "$KERNELS_COMPRESSION" != "" ]; then
        arch-chroot /mnt sed -i 's/^#COMPRESSION="'"$KERNELS_COMPRESSION"'"/COMPRESSION="'"$KERNELS_COMPRESSION"'"/' /etc/mkinitcpio.conf
    fi

    if [ "$KERNELS_COMPRESSION" == "bzip2" ]; then
        pacman_install "bzip2"
    fi
    if [ "$KERNELS_COMPRESSION" == "lzma" -o "$KERNELS_COMPRESSION" == "xz" ]; then
        pacman_install "xz"
    fi
    if [ "$KERNELS_COMPRESSION" == "lzop" ]; then
        pacman_install "lzop"
    fi
    if [ "$KERNELS_COMPRESSION" == "lz4" ]; then
        pacman_install "lz4"
    fi
    if [ "$KERNELS_COMPRESSION" == "zstd" ]; then
        pacman_install "zstd"
    fi
}

function display_driver() {
    print_step "display_driver()"

    PACKAGES_DRIVER=""
    PACKAGES_DRIVER_MULTILIB=""
    PACKAGES_DDX=""
    PACKAGES_VULKAN=""
    PACKAGES_VULKAN_MULTILIB=""
    PACKAGES_HARDWARE_ACCELERATION=""
    PACKAGES_HARDWARE_ACCELERATION_MULTILIB=""
    case "$DISPLAY_DRIVER" in
        "intel" )
            PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "amdgpu" )
            PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "ati" )
            PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "nvidia" )
            PACKAGES_DRIVER="nvidia"
            PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-lts" )
            PACKAGES_DRIVER="nvidia-lts"
            PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-dkms" )
            PACKAGES_DRIVER="nvidia-dkms"
            PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-390xx" )
            PACKAGES_DRIVER="nvidia-390xx"
            PACKAGES_DRIVER_MULTILIB=""
            ;;
        "nvidia-390xx-lts" )
            PACKAGES_DRIVER="nvidia-390xx-lts"
            PACKAGES_DRIVER_MULTILIB=""
            ;;
        "nvidia-390xx-dkms" )
            PACKAGES_DRIVER="nvidia-390xx-dkms"
            PACKAGES_DRIVER_MULTILIB=""
            ;;
        "nouveau" )
            PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
    esac
    if [ "$DISPLAY_DRIVER_DDX" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                PACKAGES_DDX="xf86-video-intel"
                ;;
            "amdgpu" )
                PACKAGES_DDX="xf86-video-amdgpu"
                ;;
            "ati" )
                PACKAGES_DDX="xf86-video-ati"
                ;;
            "nouveau" )
                PACKAGES_DDX="xf86-video-nouveau"
                ;;
        esac
    fi
    if [ "$VULKAN" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                PACKAGES_VULKAN="vulkan-icd-loader vulkan-intel"
                PACKAGES_VULKAN_MULTILIB="lib32-vulkan-icd-loader lib32-vulkan-intel"
                ;;
            "amdgpu" )
                PACKAGES_VULKAN="vulkan-radeon"
                PACKAGES_VULKAN_MULTILIB="lib32-vulkan-radeon"
                ;;
            "ati" )
                PACKAGES_VULKAN="vulkan-radeon"
                PACKAGES_VULKAN_MULTILIB="lib32-vulkan-radeon"
                ;;
            "nvidia" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils"
                ;;
            "nvidia-lts" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils"
                ;;
            "nvidia-dkms" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils"
                ;;
            "nvidia-390xx" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB=""
                ;;
            "nvidia-390xx-lts" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB=""
                ;;
            "nvidia-390xx-dkms" )
                PACKAGES_VULKAN="nvidia-utils"
                PACKAGES_VULKAN_MULTILIB=""
                ;;
            "nouveau" )
                PACKAGES_VULKAN=""
                PACKAGES_VULKAN_MULTILIB=""
                ;;
        esac
    fi
    if [ "$DISPLAY_DRIVER_HARDWARE_ACCELERATION" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                if [ -n "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" ]; then
                    PACKAGES_HARDWARE_ACCELERATION=$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL
                    PACKAGES_HARDWARE_ACCELERATION_MULTILIB=""
                fi
                ;;
            "amdgpu" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "ati" )
                PACKAGES_HARDWARE_ACCELERATION="mesa-vdpau"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-mesa-vdpau"
                ;;
            "nvidia" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-lts" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-dkms" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-390xx" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-390xx-lts" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-390xx-dkms" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nouveau" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
        esac
    fi

    pacman_install "mesa $PACKAGES_DRIVER $PACKAGES_DDX $PACKAGES_VULKAN $PACKAGES_HARDWARE_ACCELERATION"

    if [ "$PACKAGES_MULTILIB" == "true" ]; then
        pacman_install "$PACKAGES_DRIVER_MULTILIB $PACKAGES_VULKAN_MULTILIB $PACKAGES_HARDWARE_ACCELERATION_MULTILIB"
    fi
}

function kernels() {
    print_step "kernels()"

    pacman_install "linux-headers"
    if [ -n "$KERNELS" ]; then
        pacman_install "$KERNELS"
    fi
}

function mkinitcpio() {
    print_step "mkinitcpio()"

    arch-chroot /mnt mkinitcpio -P
}

function network() {
    print_step "network()"

    pacman_install "networkmanager"
    arch-chroot /mnt systemctl enable NetworkManager.service
}

function virtualbox() {
    print_step "virtualbox()"

    if [ -z "$KERNELS" ]; then
        pacman_install "virtualbox-guest-utils"
    else
        pacman_install "virtualbox-guest-utils virtualbox-guest-dkms"
    fi
}

function users() {
    print_step "users()"

    create_user "$USER_NAME" "$USER_PASSWORD"

    for U in ${ADDITIONAL_USERS[@]}; do
        IFS='=' S=(${U})
        USER=${S[0]}
        PASSWORD=${S[1]}
        create_user "${USER}" "${PASSWORD}"
    done

	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

    pacman_install "xdg-user-dirs"

    if [ "$SYSTEMD_HOMED" == "true" ]; then
        cat <<EOT > "/mnt/etc/pam.d/nss-auth"
#%PAM-1.0

auth     sufficient pam_unix.so try_first_pass nullok
auth     sufficient pam_systemd_home.so
auth     required   pam_deny.so

account  sufficient pam_unix.so
account  sufficient pam_systemd_home.so
account  required   pam_deny.so

password sufficient pam_unix.so try_first_pass nullok sha512 shadow
password sufficient pam_systemd_home.so
password required   pam_deny.so
EOT

        cat <<EOT > "/mnt/etc/pam.d/system-auth"
#%PAM-1.0

auth      substack   nss-auth
auth      optional   pam_permit.so
auth      required   pam_env.so

account   substack   nss-auth
account   optional   pam_permit.so
account   required   pam_time.so

password  substack   nss-auth
password  optional   pam_permit.so

session   required  pam_limits.so
session   optional  pam_systemd_home.so
session   required  pam_unix.so
session   optional  pam_permit.so
EOT
    fi
}

function create_user() {
    USER=$1
    PASSWORD=$2
    if [ "$SYSTEMD_HOMED" == "true" ]; then
        arch-chroot /mnt systemctl enable systemd-homed.service
        create_user_homectl $USER $PASSWORD
#       create_user_useradd $USER $PASSWORD
    else
        create_user_useradd $USER $PASSWORD
    fi
}

function create_user_homectl() {
    USER=$1
    PASSWORD=$2
    STORAGE=""
    CIFS_DOMAIN=""
    CIFS_USERNAME=""
    CIFS_SERVICE=""
    TZ=$(echo ${TIMEZONE} | sed "s/\/usr\/share\/zoneinfo\///g")
    L=$(echo ${LOCALE_CONF[0]} | sed "s/LANG=//g")
    IMAGE_PATH="/home/$USER.homedir"
    HOME_PATH="/home/$USER"

    if [ -n "$SYSTEMD_HOMED_STORAGE" ]; then
        STORAGE="--storage=$SYSTEMD_HOMED_STORAGE"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "cifs" ]; then
        CIFS_DOMAIN="--cifs-domain=$SYSTEMD_HOMED_CIFS_DOMAIN"
        CIFS_USERNAME="--cifs-user-name=$USER"
        CIFS_SERVICE="--cifs-service=$SYSTEMD_HOMED_CIFS_SERVICE"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "luks" ]; then
        IMAGE_PATH="/home/$USER.home"
    fi

    ### something missing, inside alis this not works, after install the user is in state infixated
    ### after install and reboot this commands work
    systemctl start systemd-homed.service
    set +e
    homectl create "$USER" --enforce-password-policy=no --timezone=$TZ --language=$L $STORAGE $CIFS_DOMAIN $CIFS_USERNAME $CIFS_SERVICE -G wheel,storage,optical
    homectl activate "$USER"
    set -e
    cp -a "$IMAGE_PATH/." "/mnt$IMAGE_PATH"
    cp -a "$HOME_PATH/." "/mnt$HOME_PATH"
    cp -a "/var/lib/systemd/home/." "/mnt/var/lib/systemd/home/"
}

function create_user_useradd() {
    USER=$1
    PASSWORD=$2
    arch-chroot /mnt useradd -m -G wheel,storage,optical -s /bin/bash $USER
    printf "$PASSWORD\n$PASSWORD" | arch-chroot /mnt passwd $USER
}

function bootloader() {
    print_step "bootloader()"

    BOOTLOADER_ALLOW_DISCARDS=""

    if [ "$VIRTUALBOX" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            pacman_install "intel-ucode"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            pacman_install "amd-ucode"
        fi
    fi
    if [ "$LVM" == "true" ]; then
        CMDLINE_LINUX_ROOT="root=$DEVICE_ROOT"
    else
        CMDLINE_LINUX_ROOT="root=PARTUUID=$PARTUUID_ROOT"
    fi
    if [ -n "$LUKS_PASSWORD" ]; then
        if [ "$DEVICE_TRIM" == "true" ]; then
            BOOTLOADER_ALLOW_DISCARDS=":allow-discards"
        fi
        CMDLINE_LINUX="cryptdevice=PARTUUID=$PARTUUID_ROOT:$LUKS_DEVICE_NAME$BOOTLOADER_ALLOW_DISCARDS"
    fi
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        CMDLINE_LINUX="$CMDLINE_LINUX rootflags=subvol=root"
    fi
    if [ "$KMS" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "nvidia" | "nvidia-390xx" | "nvidia-390xx-lts" )
                CMDLINE_LINUX="$CMDLINE_LINUX nvidia-drm.modeset=1"
                ;;
        esac
    fi

    if [ -n "$KERNELS_PARAMETERS" ]; then
        CMDLINE_LINUX="$CMDLINE_LINUX $KERNELS_PARAMETERS"
    fi

    case "$BOOTLOADER" in
        "grub" )
            bootloader_grub
            ;;
        "refind" )
            bootloader_refind
            ;;
        "systemd" )
            bootloader_systemd
            ;;
    esac

    arch-chroot /mnt systemctl set-default multi-user.target
}

function bootloader_grub() {
    pacman_install "grub dosfstools"
    arch-chroot /mnt sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
    arch-chroot /mnt sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
    arch-chroot /mnt sed -i -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
    arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="'"$CMDLINE_LINUX"'"/' /etc/default/grub
    echo "" >> /mnt/etc/default/grub
    echo "# alis" >> /mnt/etc/default/grub
    echo "GRUB_DISABLE_SUBMENU=y" >> /mnt/etc/default/grub

    if [ "$BIOS_TYPE" == "uefi" ]; then
        pacman_install "efibootmgr"
        arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=$ESP_DIRECTORY --recheck
        #arch-chroot /mnt efibootmgr --create --disk $DEVICE --part $PARTITION_BOOT_NUMBER --loader /EFI/grub/grubx64.efi --label "GRUB Boot Manager"
    fi
    if [ "$BIOS_TYPE" == "bios" ]; then
        arch-chroot /mnt grub-install --target=i386-pc --recheck $DEVICE
    fi

    arch-chroot /mnt grub-mkconfig -o "$BOOT_DIRECTORY/grub/grub.cfg"

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\grub\grubx64.efi" > "/mnt$ESP_DIRECTORY/startup.nsh"
    fi
}

function bootloader_refind() {
    pacman_install "refind-efi"
    arch-chroot /mnt refind-install

    arch-chroot /mnt rm /boot/refind_linux.conf
    arch-chroot /mnt sed -i 's/^timeout.*/timeout 5/' "$ESP_DIRECTORY/EFI/refind/refind.conf"
    arch-chroot /mnt sed -i 's/^#scan_all_linux_kernels.*/scan_all_linux_kernels false/' "$ESP_DIRECTORY/EFI/refind/refind.conf"
    #arch-chroot /mnt sed -i 's/^#default_selection "+,bzImage,vmlinuz"/default_selection "+,bzImage,vmlinuz"/' "$ESP_DIRECTORY/EFI/refind/refind.conf"

    REFIND_MICROCODE=""

    if [ "$VIRTUALBOX" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            REFIND_MICROCODE="initrd=/intel-ucode.img"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            REFIND_MICROCODE="initrd=/amd-ucode.img"
        fi
    fi

    cat <<EOT >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
# alis
menuentry "Arch Linux" {
    volume   $PARTUUID_BOOT
    loader   /vmlinuz-linux
    initrd   /initramfs-linux.img
    icon     /EFI/refind/icons/os_arch.png
    options  "$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX"
    submenuentry "Boot using fallback initramfs"
	      initrd /initramfs-linux-fallback.img"
    }
    submenuentry "Boot to terminal"
	      add_options "systemd.unit=multi-user.target"
    }
}

EOT
    if [[ $KERNELS =~ .*linux-lts.* ]]; then
        cat <<EOT >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
menuentry "Arch Linux (lts)" {
    volume   $PARTUUID_BOOT
    loader   /vmlinuz-linux-lts
    initrd   /initramfs-linux-lts.img
    icon     /EFI/refind/icons/os_arch.png
    options  "$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX"
    submenuentry "Boot using fallback initramfs" {
	      initrd /initramfs-linux-lts-fallback.img
    }
    submenuentry "Boot to terminal" {
	      add_options "systemd.unit=multi-user.target"
    }
}

EOT
    fi
    if [[ $KERNELS =~ .*linux-hardened.* ]]; then
        cat <<EOT >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
menuentry "Arch Linux (hardened)" {
    volume   $PARTUUID_BOOT
    loader   /vmlinuz-linux-hardened
    initrd   /initramfs-linux-hardened.img
    icon     /EFI/refind/icons/os_arch.png
    options  "$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX"
    submenuentry "Boot using fallback initramfs" {
	      initrd /initramfs-linux-lts-fallback.img
    }
    submenuentry "Boot to terminal" {
	      add_options "systemd.unit=multi-user.target"
    }
}

EOT
    fi
    if [[ $KERNELS =~ .*linux-zen.* ]]; then
        cat <<EOT >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
menuentry "Arch Linux (zen)" {
    volume   $PARTUUID_BOOT
    loader   /vmlinuz-linux-zen
    initrd   /initramfs-linux-zen.img
    icon     /EFI/refind/icons/os_arch.png
    options  "$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX"
    submenuentry "Boot using fallback initramfs" {
	      initrd /initramfs-linux-lts-fallback.img
    }
    submenuentry "Boot to terminal" {
	      add_options "systemd.unit=multi-user.target"
    }
}

EOT
    fi

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\refind\refind_x64.efi" > "/mnt$ESP_DIRECTORY/startup.nsh"
    fi
}

function bootloader_systemd() {
    arch-chroot /mnt systemd-machine-id-setup
    arch-chroot /mnt bootctl --path="$ESP_DIRECTORY" install

    arch-chroot /mnt mkdir -p "$ESP_DIRECTORY/loader/"
    arch-chroot /mnt mkdir -p "$ESP_DIRECTORY/loader/entries/"

    cat <<EOT > "/mnt$ESP_DIRECTORY/loader/loader.conf"
# alis
timeout 5
default archlinux
editor 0
EOT

    arch-chroot /mnt mkdir -p "/etc/pacman.d/hooks/"

    cat <<EOT > "/mnt/etc/pacman.d/hooks/systemd-boot.hook"
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot
When = PostTransaction
Exec = /usr/bin/bootctl update
EOT

    SYSTEMD_MICROCODE=""
    SYSTEMD_OPTIONS=""

    if [ "$VIRTUALBOX" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            SYSTEMD_MICROCODE="/intel-ucode.img"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            SYSTEMD_MICROCODE="/amd-ucode.img"
        fi
    fi

    if [ -n "$LUKS_PASSWORD" ]; then
       SYSTEMD_OPTIONS="luks.name=$UUID_ROOT=$LUKS_DEVICE_NAME luks.options=discard"
    fi

    echo "title Arch Linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    echo "efi /vmlinuz-linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    fi
    echo "initrd /initramfs-linux.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    echo "options initrd=initramfs-linux.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"

    echo "title Arch Linux (terminal)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-terminal.conf"
    echo "efi /vmlinuz-linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-terminal.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-terminal.conf"
    fi
    echo "initrd /initramfs-linux.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-terminal.conf"
    echo "options initrd=initramfs-linux.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-terminal.conf"

    echo "title Arch Linux (fallback)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-fallback.conf"
    echo "efi /vmlinuz-linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-fallback.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-fallback.conf"
    fi
    echo "initrd /initramfs-linux-fallback.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-fallback.conf"
    echo "options initrd=initramfs-linux-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-fallback.conf"

    if [[ $KERNELS =~ .*linux-lts.* ]]; then
        echo "title Arch Linux (lts)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"
        echo "efi /vmlinuz-linux-lts" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"
        fi
        echo "initrd /initramfs-linux-lts.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"
        echo "options initrd=initramfs-linux-lts.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"

        echo "title Arch Linux (lts, terminal)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-terminal.conf"
        echo "efi /vmlinuz-linux-lts" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-terminal.conf"
        fi
        echo "initrd /initramfs-linux-lts.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-terminal.conf"
        echo "options initrd=initramfs-linux-lts.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-terminal.conf"

        echo "title Arch Linux (lts-fallback)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-fallback.conf"
        echo "efi /vmlinuz-linux-lts" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-fallback.conf"
        if [ "$CPU_INTEL" == "true" -a "$VIRTUALBOX" != "true" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-fallback.conf"
        fi
        echo "initrd /initramfs-linux-lts-fallback.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-fallback.conf"
        echo "options initrd=initramfs-linux-lts-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts-fallback.conf"
    fi

    if [[ $KERNELS =~ .*linux-hardened.* ]]; then
        echo "title Arch Linux (hardened)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"
        echo "efi /vmlinuz-linux-hardened" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"
        fi
        echo "initrd /initramfs-linux-hardened.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"
        echo "options initrd=initramfs-linux-hardened.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"

        echo "title Arch Linux (hardened, terminal)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-terminal.conf"
        echo "efi /vmlinuz-linux-hardened" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-terminal.conf"
        fi
        echo "initrd /initramfs-linux-hardened.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-terminal.conf"
        echo "options initrd=initramfs-linux-hardened.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-terminal.conf"

        echo "title Arch Linux (hardened-fallback)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-fallback.conf"
        echo "efi /vmlinuz-linux-hardened" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-fallback.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-fallback.conf"
        fi
        echo "initrd /initramfs-linux-hardened-fallback.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-fallback.conf"
        echo "options initrd=initramfs-linux-hardened-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened-fallback.conf"
    fi

    if [[ $KERNELS =~ .*linux-zen.* ]]; then
        echo "title Arch Linux (zen)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"
        echo "efi /vmlinuz-linux-zen" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"
        fi
        echo "initrd /initramfs-linux-zen.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"
        echo "options initrd=initramfs-linux-zen.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"

        echo "title Arch Linux (zen, terminal)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-terminal.conf"
        echo "efi /vmlinuz-linux-zen" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-terminal.conf"
        fi
        echo "initrd /initramfs-linux-zen.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-terminal.conf"
        echo "options initrd=initramfs-linux-zen.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-terminal.conf"

        echo "title Arch Linux (zen-fallback)" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-fallback.conf"
        echo "efi /vmlinuz-linux-zen" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-fallback.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-fallback.conf"
        fi
        echo "initrd /initramfs-linux-zen-fallback.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-fallback.conf"
        echo "options initrd=initramfs-linux-zen-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen-fallback.conf"
    fi

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\systemd\systemd-bootx64.efi" > "/mnt$ESP_DIRECTORY/startup.nsh"
    fi
}

function custom_shell() {
    print_step "custom_shell()"

    CUSTOM_SHELL_PATH=""
    case "$CUSTOM_SHELL" in
        "zsh" )
            pacman_install "zsh"
            CUSTOM_SHELL_PATH="/usr/bin/zsh"
            ;;
        "dash" )
            pacman_install "dash"
            CUSTOM_SHELL_PATH="/usr/bin/dash"
            ;;
        "fish" )
            pacman_install "fish"
            CUSTOM_SHELL_PATH="/usr/bin/fish"
            ;;
    esac

    if [ -n "$CUSTOM_SHELL_PATH" ]; then
        custom_shell_user "root" $CUSTOM_SHELL_PATH
        custom_shell_user "$USER_NAME" $CUSTOM_SHELL_PATH
        for U in ${ADDITIONAL_USERS[@]}; do
            IFS='=' S=(${U})
            USER=${S[0]}
            custom_shell_user "$USER" $CUSTOM_SHELL_PATH
        done
    fi
}


function custom_shell_user() {
    USER=$1
    CUSTOM_SHELL_PATH=$2

    if [ "$SYSTEMD_HOMED" == "true" ]; then
        homectl update --shell=$CUSTOM_SHELL_PATH $USER
    else
        arch-chroot /mnt chsh -s $CUSTOM_SHELL_PATH $USER
    fi
}

function desktop_environment() {
    print_step "desktop_environment()"

    case "$DESKTOP_ENVIRONMENT" in
        "gnome" )
            desktop_environment_gnome
            ;;
        "kde" )
            desktop_environment_kde
            ;;
        "xfce" )
            desktop_environment_xfce
            ;;
        "mate" )
            desktop_environment_mate
            ;;
        "cinnamon" )
            desktop_environment_cinnamon
            ;;
        "lxde" )
            desktop_environment_lxde
            ;;
        "i3-wm" )
            desktop_environment_i3_wm
            ;;
        "i3-gaps" )
            desktop_environment_i3_gaps
            ;;
    esac

    arch-chroot /mnt systemctl set-default graphical.target
}

function desktop_environment_gnome() {
    pacman_install "gnome"
    arch-chroot /mnt systemctl enable gdm.service
}

function desktop_environment_kde() {
    pacman_install "plasma-meta plasma-wayland-session kde-applications-meta"
    arch-chroot /mnt systemctl enable sddm.service
}

function desktop_environment_xfce() {
    pacman_install "xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xorg-server"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_mate() {
    pacman_install "mate mate-extra lightdm lightdm-gtk-greeter xorg-server"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_cinnamon() {
    pacman_install "cinnamon lightdm lightdm-gtk-greeter xorg-server"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_lxde() {
    pacman_install "lxde lxdm"
    arch-chroot /mnt systemctl enable lxdm.service
}

function desktop_environment_i3_wm() {
    pacman_install "i3-wm i3blocks i3lock i3status dmenu rxvt-unicode lightdm lightdm-gtk-greeter xorg-server"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_i3_gaps() {
    pacman_install "i3-gaps i3blocks i3lock i3status dmenu rxvt-unicode lightdm lightdm-gtk-greeter xorg-server"
    arch-chroot /mnt systemctl enable lightdm.service
}

function packages() {
    if [ "$PACKAGES_INSTALL" == "true" ]; then
        (USER_NAME=$USER_NAME \
         USER_PASSWORD=$USER_PASSWORD \
            ./alis-packages.sh)
    fi
}

function vagrant() {
    pacman_install "openssh"
    create_user "vagrant" "vagrant"
    arch-chroot /mnt systemctl enable sshd.service
    arch-chroot /mnt ssh-keygen -A
    arch-chroot /mnt sshd -t
}

function systemd_units() {
    IFS=' ' UNITS=($SYSTEMD_UNITS)
    for U in ${UNITS[@]}; do
        ACTION=""
        UNIT=${U}
        if [[ $UNIT == -* ]]; then
            ACTION="disable"
            UNIT=$(echo $UNIT | sed "s/^-//g")
        elif [[ $UNIT == +* ]]; then
            ACTION="enable"
            UNIT=$(echo $UNIT | sed "s/^+//g")
        elif [[ $UNIT =~ ^[a-zA-Z0-9]+ ]]; then
            ACTION="enable"
            UNIT=$UNIT
        fi

        if [ -n "$ACTION" ]; then
            arch-chroot /mnt systemctl $ACTION $UNIT
        fi
    done
}

function end() {
    echo ""
    echo -e "${GREEN}Arch Linux installed successfully"'!'"${NC}"
    echo ""

    if [ "$REBOOT" == "true" ]; then
        REBOOT="true"

        set +e
        for (( i = 15; i >= 1; i-- )); do
            read -r -s -n 1 -t 1 -p "Rebooting in $i seconds... Press any key to abort."$'\n' KEY
            if [ $? -eq 0 ]; then
                REBOOT="false"
                break
            fi
        done
        set -e

        if [ "$REBOOT" == 'true' ]; then
            echo "Rebooting..."
            echo ""

            copy_logs
            do_reboot
        else
            if [ "$ASCIINEMA" == "true" ]; then
                echo "Reboot aborted. You will must terminate asciinema recording and do a explicit reboot (exit, ./alis-reboot.sh)."
                echo ""
            else
                echo "Reboot aborted. You will must do a explicit reboot (./alis-reboot.sh)."
                echo ""
            fi
        fi
    else
        if [ "$ASCIINEMA" == "true" ]; then
            echo "No reboot. You will must terminate asciinema recording and do a explicit reboot (exit, ./alis-reboot.sh)."
            echo ""
        else
            echo "No reboot. You will must do a explicit reboot (./alis-reboot.sh)."
            echo ""
        fi
    fi
}

function pacman_install() {
    ERROR="true"
    set +e
    IFS=' ' PACKAGES=($1)
    for VARIABLE in {1..5}
    do
        arch-chroot /mnt pacman -Syu --noconfirm --needed ${PACKAGES[@]}
        if [ $? == 0 ]; then
            ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        exit
    fi
}

function copy_logs() {
    ESCAPED_LUKS_PASSWORD=$(echo "${LUKS_PASSWORD}" | sed 's/[.[\*^$()+?{|]/[\\&]/g')
    ESCAPED_ROOT_PASSWORD=$(echo "${ROOT_PASSWORD}" | sed 's/[.[\*^$()+?{|]/[\\&]/g')
    ESCAPED_USER_PASSWORD=$(echo "${USER_PASSWORD}" | sed 's/[.[\*^$()+?{|]/[\\&]/g')

    if [ -f "$CONF_FILE" ]; then
        SOURCE_FILE="$CONF_FILE"
        FILE="/mnt/var/log/alis/$CONF_FILE"

        mkdir -p /mnt/var/log/alis
        cp "$SOURCE_FILE" "$FILE"
        chown root:root "$FILE"
        chmod 600 "$FILE"
        if [ -n "$ESCAPED_LUKS_PASSWORD" ]; then
            sed -i "s/${ESCAPED_LUKS_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_ROOT_PASSWORD" ]; then
            sed -i "s/${ESCAPED_ROOT_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_USER_PASSWORD" ]; then
            sed -i "s/${ESCAPED_USER_PASSWORD}/******/g" "$FILE"
        fi
    fi
    if [ -f "$LOG_FILE" ]; then
        SOURCE_FILE="$LOG_FILE"
        FILE="/mnt/var/log/alis/$LOG_FILE"

        mkdir -p /mnt/var/log/alis
        cp "$SOURCE_FILE" "$FILE"
        chown root:root "$FILE"
        chmod 600 "$FILE"
        if [ -n "$ESCAPED_LUKS_PASSWORD" ]; then
            sed -i "s/${ESCAPED_LUKS_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_ROOT_PASSWORD" ]; then
            sed -i "s/${ESCAPED_ROOT_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_USER_PASWORD" ]; then
            sed -i "s/${ESCAPED_USER_PASSWORD}/******/g" "$FILE"
        fi
    fi
    if [ -f "$ASCIINEMA_FILE" ]; then
        SOURCE_FILE="$ASCIINEMA_FILE"
        FILE="/mnt/var/log/alis/$ASCIINEMA_FILE"

        mkdir -p /mnt/var/log/alis
        cp "$SOURCE_FILE" "$FILE"
        chown root:root "$FILE"
        chmod 600 "$FILE"
        if [ -n "$ESCAPED_LUKS_PASSWORD" ]; then
            sed -i "s/${ESCAPED_LUKS_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_ROOT_PASSWORD" ]; then
            sed -i "s/${ESCAPED_ROOT_PASSWORD}/******/g" "$FILE"
        fi
        if [ -n "$ESCAPED_USER_PASSWORD" ]; then
            sed -i "s/${ESCAPED_USER_PASSWORD}/******/g" "$FILE"
        fi
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

function load_globals() {
    if [ -f "$GLOBALS_FILE" ]; then
        source "$GLOBALS_FILE"
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
CMDLINE_LINUX_ROOT="$CMDLINE_LINUX_ROOT"
CMDLINE_LINUX="$CMDLINE_LINUX"
EOT
}

function main() {
    ALL_STEPS=("configuration_install" "sanitize_variables" "check_variables" "warning" "init" "facts" "checks" "prepare" "partition" "install" "configuration" "mkinitcpio_configuration" "display_driver" "kernels" "mkinitcpio" "network" "virtualbox" "users" "bootloader" "custom_shell" "desktop_environment" "packages" "vagrant" "systemd_units" "end")
    STEP="configuration_install"

    if [ -n "$1" ]; then
        STEP="$1"
    fi
    if [ "$STEP" == "steps" ]; then
        echo "Steps: $ALL_STEPS"
        return 0
    fi

    # get step execute from
    FOUND="false"
    STEPS=""
    for S in ${ALL_STEPS[@]}; do
        if [ $FOUND = "true" -o "${STEP}" = "${S}" ]; then
            FOUND="true"
            STEPS="$STEPS $S"
        fi
    done

    # execute steps
    load_globals

    execute_step "configuration_install" "${STEPS}"
    execute_step "sanitize_variables" "${STEPS}"
    execute_step "check_variables" "${STEPS}"
    execute_step "warning" "${STEPS}"
    execute_step "init" "${STEPS}"
    execute_step "facts" "${STEPS}"
    execute_step "checks" "${STEPS}"
    execute_step "prepare" "${STEPS}"
    execute_step "partition" "${STEPS}"
    execute_step "install" "${STEPS}"
    execute_step "configuration" "${STEPS}"
    execute_step "mkinitcpio_configuration" "${STEPS}"
    if [ -n "$DISPLAY_DRIVER" ]; then
        execute_step "display_driver" "${STEPS}"
    fi
    execute_step "kernels" "${STEPS}"
    execute_step "mkinitcpio" "${STEPS}"
    execute_step "network" "${STEPS}"
    if [ "$VIRTUALBOX" == "true" ]; then
        execute_step "virtualbox" "${STEPS}"
    fi
    execute_step "users" "${STEPS}"
    execute_step "bootloader" "${STEPS}"
    if [ -n "$CUSTOM_SHELL" ]; then
        execute_step "custom_shell" "${STEPS}"
    fi
    if [ -n "$DESKTOP_ENVIRONMENT" ]; then
        execute_step "desktop_environment" "${STEPS}"
    fi
    execute_step "packages" "${STEPS}"
    if [ "$VAGRANT" == "true" ]; then
        execute_step "vagrant" "${STEPS}"
    fi
    execute_step "systemd_units" "${STEPS}"
    execute_step "end" "${STEPS}"
}

main $@
