#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
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

# Usage:
# # loadkeys es
# # curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# # vim alis.conf
# # ./alis.sh

# global variables (no configuration, don't edit)
ASCIINEMA=""
BIOS_TYPE=""
PARTITION_BIOS=""
PARTITION_BOOT=""
PARTITION_ROOT=""
DEVICE_ROOT=""
LVM_DEVICE=""
LVM_VOLUME_PHISICAL="lvm"
LVM_VOLUME_GROUP="vg"
LVM_VOLUME_LOGICAL="root"
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
CPU_INTEL=""
VIRTUALBOX=""
CMDLINE_LINUX_ROOT=""
CMDLINE_LINUX=""
ADDITIONAL_USER_NAMES_ARRAY=()
ADDITIONAL_USER_PASSWORDS_ARRAY=()

CONF_FILE="alis.conf"
LOG_FILE="alis.log"
ASCIINEMA_FILE="alis.asciinema"

RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m'

function configuration_install() {
    source alis.conf
    ADDITIONAL_USER_NAMES_ARRAY=($ADDITIONAL_USER_NAMES)
    ADDITIONAL_USER_PASSWORDS_ARRAY=($ADDITIONAL_USER_PASSWORDS)
}

function sanitize_variables() {
    DEVICE=$(sanitize_variable "$DEVICE")
    FILE_SYSTEM_TYPE=$(sanitize_variable "$FILE_SYSTEM_TYPE")
    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    KERNELS=$(sanitize_variable "$KERNELS")
    KERNELS_COMPRESSION=$(sanitize_variable "$KERNELS_COMPRESSION")
    BOOTLOADER=$(sanitize_variable "$BOOTLOADER")
    DESKTOP_ENVIRONMENT=$(sanitize_variable "$DESKTOP_ENVIRONMENT")
    DISPLAY_DRIVER=$(sanitize_variable "$DISPLAY_DRIVER")
    DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL=$(sanitize_variable "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL")
    PACKAGES_PACMAN=$(sanitize_variable "$PACKAGES_PACMAN")
    AUR=$(sanitize_variable "$AUR")
    PACKAGES_AUR=$(sanitize_variable "$PACKAGES_AUR")
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
    check_variables_boolean "LVM" "$LVM"
    check_variables_equals "PARTITION_ROOT_ENCRYPTION_PASSWORD" "PARTITION_ROOT_ENCRYPTION_PASSWORD_RETYPE" "$PARTITION_ROOT_ENCRYPTION_PASSWORD" "$PARTITION_ROOT_ENCRYPTION_PASSWORD_RETYPE"
    check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 btrfs xfs"
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_value "PACMAN_MIRROR" "$PACMAN_MIRROR"
    check_variables_list "KERNELS" "$KERNELS" "linux-lts linux-lts-headers linux-hardened linux-hardened-headers linux-zen linux-zen-headers" "false"
    check_variables_list "KERNELS_COMPRESSION" "$KERNELS_COMPRESSION" "gzip bzip2 lzma xz lzop lz4" "false"
    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALE" "$LOCALE"
    check_variables_value "LANG" "$LANG"
    check_variables_value "KEYMAP" "$KEYMAP"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_equals "ROOT_PASSWORD" "ROOT_PASSWORD_RETYPE" "$ROOT_PASSWORD" "$ROOT_PASSWORD_RETYPE"
    check_variables_equals "USER_PASSWORD" "USER_PASSWORD_RETYPE" "$USER_PASSWORD" "$USER_PASSWORD_RETYPE"
    check_variables_size "ADDITIONAL_USER_PASSWORDS" "${#ADDITIONAL_USER_NAMES_ARRAY[@]}" "${#ADDITIONAL_USER_PASSWORDS_ARRAY[@]}"
    check_variables_list "BOOTLOADER" "$BOOTLOADER" "grub refind systemd"
    check_variables_list "AUR" "$AUR" "aurman yay" "false"
    check_variables_list "DESKTOP_ENVIRONMENT" "$DESKTOP_ENVIRONMENT" "gnome kde xfce mate cinnamon lxde" "false"
    check_variables_list "DISPLAY_DRIVER" "$DISPLAY_DRIVER" "intel amdgpu ati nvidia nvidia-lts nvidia-dkms nvidia-390xx nvidia-390xx-lts nvidia-390xx-dkms nouveau" "false"
    check_variables_boolean "KMS" "$KMS"
    check_variables_boolean "DISPLAY_DRIVER_DDX" "$DISPLAY_DRIVER_DDX"
    check_variables_boolean "DISPLAY_DRIVER_HARDWARE_ACCELERATION" "$DISPLAY_DRIVER_HARDWARE_ACCELERATION"
    check_variables_list "DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" "intel-media-driver libva-intel-driver" "false"
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
    echo ""
    echo -e "${LIGHT_BLUE}# init() step${NC}"
    echo ""

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
    echo ""
    echo -e "${LIGHT_BLUE}# facts() step${NC}"
    echo ""

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
        CPU_INTEL="true"
    fi

    if [ -n "$(lspci | grep -i virtualbox)" ]; then
        VIRTUALBOX="true"
    fi
}

function check_facts() {
    if [ "$BOOTLOADER" == "refind" ]; then
        check_variables_list "BIOS_TYPE" "$BIOS_TYPE" "uefi"
    fi
    if [ "$BOOTLOADER" == "systemd" ]; then
        check_variables_list "BIOS_TYPE" "$BIOS_TYPE" "uefi"
    fi
}

function prepare() {
    echo ""
    echo -e "${LIGHT_BLUE}# prepare() step${NC}"
    echo ""

    configure_time
    prepare_partition
    configure_network
}

function configure_time() {
    timedatectl set-ntp true
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
    if [ -e "/dev/mapper/$LVM_VOLUME_PHISICAL" ]; then
        lvremove --force "$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
        vgremove --force "/dev/mapper/$LVM_VOLUME_GROUP"
        pvremove "/dev/mapper/$LVM_VOLUME_PHISICAL"
        if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
            cryptsetup close $LVM_VOLUME_PHISICAL
        fi
    fi
    partprobe $DEVICE
}

function configure_network() {
    if [ -n "$WIFI_INTERFACE" ]; then
        cp /etc/netctl/examples/wireless-wpa /etc/netctl
        chmod 600 /etc/netctl/wireless-wpa

        sed -i 's/^Interface=.*/Interface='"$WIFI_INTERFACE"'/' /etc/netctl/wireless-wpa
        sed -i 's/^ESSID=.*/ESSID='"$WIFI_ESSID"'/' /etc/netctl/wireless-wpa
        sed -i 's/^Key=.*/Key='"$WIFI_KEY"'/' /etc/netctl/wireless-wpa
        if [ "$WIFI_HIDDEN" == "true" ]; then
            sed -i 's/^#Hidden=.*/Hidden=yes/' /etc/netctl/wireless-wpa
        fi

        netctl stop-all
        netctl start wireless-wpa
        sleep 10
    fi

    ping -c 5 $PING_HOSTNAME
    if [ $? -ne 0 ]; then
        echo "Network ping check failed. Cannot continue."
        exit
    fi
}

function partition() {
    echo ""
    echo -e "${LIGHT_BLUE}# partition() step${NC}"
    echo ""

    sgdisk --zap-all $DEVICE
    wipefs -a $DEVICE

    if [ "$BIOS_TYPE" == "uefi" ]; then
        if [ "$DEVICE_SATA" == "true" ]; then
            PARTITION_BOOT="${DEVICE}1"
            PARTITION_ROOT="${DEVICE}2"
            #PARTITION_BOOT_NUMBER=1
            DEVICE_ROOT="${DEVICE}2"
        fi

        if [ "$DEVICE_NVME" == "true" ]; then
            PARTITION_BOOT="${DEVICE}p1"
            PARTITION_ROOT="${DEVICE}p2"
            #PARTITION_BOOT_NUMBER=1
            DEVICE_ROOT="${DEVICE}p2"
        fi
        
        if [ "$DEVICE_MMC" == "true" ]; then
            PARTITION_BOOT="${DEVICE}p1"
            PARTITION_ROOT="${DEVICE}p2"
            #PARTITION_BOOT_NUMBER=1
            DEVICE_ROOT="${DEVICE}p2"
        fi

        parted -s $DEVICE mklabel gpt mkpart primary fat32 1MiB 512MiB mkpart primary $FILE_SYSTEM_TYPE 512MiB 100% set 1 boot on
        sgdisk -t=1:ef00 $DEVICE
        if [ "$LVM" == "true" ]; then
            sgdisk -t=2:8e00 $DEVICE
        fi
    fi

    if [ "$BIOS_TYPE" == "bios" ]; then
        if [ "$DEVICE_SATA" == "true" ]; then
            PARTITION_BIOS="${DEVICE}1"
            PARTITION_BOOT="${DEVICE}2"
            PARTITION_ROOT="${DEVICE}3"
            #PARTITION_BOOT_NUMBER=2
            DEVICE_ROOT="${DEVICE}3"
        fi

        if [ "$DEVICE_NVME" == "true" ]; then
            PARTITION_BIOS="${DEVICE}p1"
            PARTITION_BOOT="${DEVICE}p2"
            PARTITION_ROOT="${DEVICE}p3"
            #PARTITION_BOOT_NUMBER=2
            DEVICE_ROOT="${DEVICE}p3"
        fi
        
        if [ "$DEVICE_MMC" == "true" ]; then
            PARTITION_BIOS="${DEVICE}p1"
            PARTITION_BOOT="${DEVICE}p2"
            PARTITION_ROOT="${DEVICE}p3"
            #PARTITION_BOOT_NUMBER=2
            DEVICE_ROOT="${DEVICE}p3"
        fi

        parted -s $DEVICE mklabel gpt mkpart primary fat32 1MiB 128MiB mkpart primary $FILE_SYSTEM_TYPE 128MiB 512MiB mkpart primary $FILE_SYSTEM_TYPE 512MiB 100% set 1 boot on
        sgdisk -t=1:ef02 $DEVICE
        if [ "$LVM" == "true" ]; then
            sgdisk -t=3:8e00 $DEVICE
        fi
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        LVM_DEVICE="/dev/mapper/$LVM_VOLUME_PHISICAL"
    else
        LVM_DEVICE="$PARTITION_ROOT"
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        echo -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 $PARTITION_ROOT
        echo -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" | cryptsetup --key-file=- open $PARTITION_ROOT $LVM_VOLUME_PHISICAL
        sleep 5
    fi

    if [ "$LVM" == "true" ]; then
        pvcreate $LVM_DEVICE
        vgcreate $LVM_VOLUME_GROUP $LVM_DEVICE
        lvcreate -l 100%FREE -n $LVM_VOLUME_LOGICAL $LVM_VOLUME_GROUP

        DEVICE_ROOT="/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi

    if [ "$BIOS_TYPE" == "uefi" ]; then
        wipefs -a $PARTITION_BOOT
        wipefs -a $DEVICE_ROOT
        mkfs.fat -n ESP -F32 $PARTITION_BOOT
        mkfs."$FILE_SYSTEM_TYPE" -L root $DEVICE_ROOT
    fi

    if [ "$BIOS_TYPE" == "bios" ]; then
        wipefs -a $PARTITION_BIOS
        wipefs -a $PARTITION_BOOT
        wipefs -a $DEVICE_ROOT
        mkfs.fat -n BIOS -F32 $PARTITION_BIOS
        mkfs."$FILE_SYSTEM_TYPE" -L boot $PARTITION_BOOT
        mkfs."$FILE_SYSTEM_TYPE" -L root $DEVICE_ROOT
    fi

    PARTITION_OPTIONS=""

    if [ "$DEVICE_TRIM" == "true" ]; then
        PARTITION_OPTIONS="defaults,noatime"
    fi

    mount -o "$PARTITION_OPTIONS" "$DEVICE_ROOT" /mnt

    mkdir /mnt/boot
    mount -o "$PARTITION_OPTIONS" "$PARTITION_BOOT" /mnt/boot

    if [ -n "$SWAP_SIZE" -a "$FILE_SYSTEM_TYPE" != "btrfs" ]; then
        fallocate -l $SWAP_SIZE /mnt/swap
        chmod 600 /mnt/swap
        mkswap /mnt/swap
    fi

    BOOT_DIRECTORY=/boot
    ESP_DIRECTORY=/boot
    UUID_BOOT=$(blkid -s UUID -o value $PARTITION_BOOT)
    UUID_ROOT=$(blkid -s UUID -o value $PARTITION_ROOT)
    PARTUUID_BOOT=$(blkid -s PARTUUID -o value $PARTITION_BOOT)
    PARTUUID_ROOT=$(blkid -s PARTUUID -o value $PARTITION_ROOT)
}

function install() {
    echo ""
    echo -e "${LIGHT_BLUE}# install() step${NC}"
    echo ""

    if [ -n "$PACMAN_MIRROR" ]; then
        echo "Server=$PACMAN_MIRROR" > /etc/pacman.d/mirrorlist
    fi
    sed -i 's/#Color/Color/' /etc/pacman.conf
    sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

    pacstrap /mnt base base-devel linux

    sed -i 's/#Color/Color/' /mnt/etc/pacman.conf
    sed -i 's/#TotalDownload/TotalDownload/' /mnt/etc/pacman.conf
}

function kernels() {
    echo ""
    echo -e "${LIGHT_BLUE}# kernels() step${NC}"
    echo ""

    pacman_install "linux-headers"
    if [ -n "$KERNELS" ]; then
        pacman_install "$KERNELS"
    fi
}

function configuration() {
    echo ""
    echo -e "${LIGHT_BLUE}# configuration() step${NC}"
    echo ""

    genfstab -U /mnt >> /mnt/etc/fstab

    if [ -n "$SWAP_SIZE" -a "$FILE_SYSTEM_TYPE" != "btrfs" ]; then
        echo "# swap" >> /mnt/etc/fstab
        echo "/swap none swap defaults 0 0" >> /mnt/etc/fstab
        echo "" >> /mnt/etc/fstab
    fi

    if [ "$DEVICE_TRIM" == "true" ]; then
        sed -i 's/relatime/noatime/' /mnt/etc/fstab
        arch-chroot /mnt systemctl enable fstrim.timer
    fi

    arch-chroot /mnt ln -s -f $TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    sed -i "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo -e "$LANG\n$LANGUAGE" > /mnt/etc/locale.conf
    echo -e "$KEYMAP\n$FONT\n$FONT_MAP" > /mnt/etc/vconsole.conf
    echo $HOSTNAME > /mnt/etc/hostname

    if [ -n "$SWAP_SIZE" ]; then
        echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-sysctl.conf
    fi

    printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | arch-chroot /mnt passwd
}

function network() {
    echo ""
    echo -e "${LIGHT_BLUE}# network() step${NC}"
    echo ""

    pacman_install "networkmanager"
    arch-chroot /mnt systemctl enable NetworkManager.service
}

function virtualbox() {
    echo ""
    echo -e "${LIGHT_BLUE}# virtualbox() step${NC}"
    echo ""

    if [ -z "$KERNELS" ]; then
        pacman_install "virtualbox-guest-utils virtualbox-guest-modules-arch"
    else
        pacman_install "virtualbox-guest-utils virtualbox-guest-dkms"
    fi
}

function mkinitcpio() {
    echo ""
    echo -e "${LIGHT_BLUE}# mkinitcpio() step${NC}"
    echo ""

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
        arch-chroot /mnt sed -i "s/MODULES=()/MODULES=($MODULES)/" /etc/mkinitcpio.conf
    fi

    if [ "$LVM" == "true" ]; then
        pacman_install "lvm2"
    fi

    if [ "$LVM" == "true" -a -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        arch-chroot /mnt sed -i 's/ block / block keyboard keymap /' /etc/mkinitcpio.conf
        arch-chroot /mnt sed -i 's/ filesystems keyboard / encrypt lvm2 filesystems /' /etc/mkinitcpio.conf
    elif [ "$LVM" == "true" ]; then
        arch-chroot /mnt sed -i 's/ filesystems / lvm2 filesystems /' /etc/mkinitcpio.conf
    elif [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        arch-chroot /mnt sed -i 's/ block / block keyboard keymap /' /etc/mkinitcpio.conf
        arch-chroot /mnt sed -i 's/ filesystems keyboard / encrypt filesystems /' /etc/mkinitcpio.conf
    fi

    if [ "$KERNELS_COMPRESSION" != "" ]; then
        arch-chroot /mnt sed -i "s/#COMPRESSION=\"$KERNELS_COMPRESSION\"/COMPRESSION=\"$KERNELS_COMPRESSION\"/" /etc/mkinitcpio.conf
    fi

    arch-chroot /mnt mkinitcpio -P
}

function bootloader() {
    echo ""
    echo -e "${LIGHT_BLUE}# bootloader() step${NC}"
    echo ""

    BOOTLOADER_ALLOW_DISCARDS=""

    if [ "$CPU_INTEL" == "true" -a "$VIRTUALBOX" != "true" ]; then
        pacman_install "intel-ucode"
    fi
    if [ "$LVM" == "true" ]; then
        CMDLINE_LINUX_ROOT="root=$DEVICE_ROOT"
    else
        CMDLINE_LINUX_ROOT="root=PARTUUID=$PARTUUID_ROOT"
    fi
    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        if [ "$DEVICE_TRIM" == "true" ]; then
            BOOTLOADER_ALLOW_DISCARDS=":allow-discards"
        fi
        CMDLINE_LINUX="cryptdevice=PARTUUID=$PARTUUID_ROOT:$LVM_VOLUME_PHISICAL$BOOTLOADER_ALLOW_DISCARDS"
    fi
    if [ "$KMS" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "nvidia" | "nvidia-390xx" | "nvidia-390xx-lts" )
                CMDLINE_LINUX="$CMDLINE_LINUX nvidia-drm.modeset=1"
                ;;
        esac
    fi

    case "$BOOTLOADER" in
        "grub" )
            grub
            ;;
        "refind" )
            refind
            ;;
        "systemd" )
            systemd
            ;;
    esac
}

function grub() {
    pacman_install "grub dosfstools"
    arch-chroot /mnt sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
    arch-chroot /mnt sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
    arch-chroot /mnt sed -i -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
    arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="'$CMDLINE_LINUX'"/' /etc/default/grub
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

function refind() {
    pacman_install "refind-efi"
    arch-chroot /mnt refind-install

    arch-chroot /mnt rm /boot/refind_linux.conf
    arch-chroot /mnt sed -i 's/^timeout.*/timeout 5/' "$ESP_DIRECTORY/EFI/refind/refind.conf"
    arch-chroot /mnt sed -i 's/^#scan_all_linux_kernels.*/scan_all_linux_kernels false/' "$ESP_DIRECTORY/EFI/refind/refind.conf"

    #arch-chroot /mnt sed -i 's/^#default_selection "+,bzImage,vmlinuz"/default_selection "+,bzImage,vmlinuz"/' "$ESP_DIRECTORY/EFI/refind/refind.conf"

    REFIND_MICROCODE=""

    if [ "$CPU_INTEL" == "true" -a "$VIRTUALBOX" != "true" ]; then
        REFIND_MICROCODE="initrd=/intel-ucode.img"
    fi

    echo "" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "# alis" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "menuentry \"Arch Linux\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    volume   $PARTUUID_BOOT" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    loader   /vmlinuz-linux" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    initrd   /initramfs-linux.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    icon     /EFI/refind/icons/os_arch.png" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    options  \"$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    submenuentry \"Boot using fallback initramfs\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "	      initrd /initramfs-linux-fallback.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    submenuentry \"Boot to terminal\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "	      add_options \"systemd.unit=multi-user.target\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "}" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    echo "" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    if [[ $KERNELS =~ .*linux-lts.* ]]; then
        echo "menuentry \"Arch Linux (lts)\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    volume   $PARTUUID_BOOT" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    loader   /vmlinuz-linux-lts" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    initrd   /initramfs-linux-lts.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    icon     /EFI/refind/icons/os_arch.png" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    options  \"$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot using fallback initramfs\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      initrd /initramfs-linux-lts-fallback.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot to terminal\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      add_options \"systemd.unit=multi-user.target\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "}" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    fi
    if [[ $KERNELS =~ .*linux-hardened.* ]]; then
        echo "menuentry \"Arch Linux (hardened)\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    volume   $PARTUUID_BOOT" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    loader   /vmlinuz-linux-hardened" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    initrd   /initramfs-linux-hardened.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    icon     /EFI/refind/icons/os_arch.png" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    options  \"$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot using fallback initramfs\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      initrd /initramfs-linux-hardened-fallback.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot to terminal\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      add_options \"systemd.unit=multi-user.target\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "}" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    fi
    if [[ $KERNELS =~ .*linux-zen.* ]]; then
        echo "menuentry \"Arch Linux (zen)\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    volume   $PARTUUID_BOOT" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    loader   /vmlinuz-linux-zen" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    initrd   /initramfs-linux-zen.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    icon     /EFI/refind/icons/os_arch.png" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    options  \"$REFIND_MICROCODE $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot using fallback initramfs\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      initrd /initramfs-linux-zen-fallback.img" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    submenuentry \"Boot to terminal\" {" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "	      add_options \"systemd.unit=multi-user.target\"" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "    }" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "}" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
        echo "" >> "/mnt$ESP_DIRECTORY/EFI/refind/refind.conf"
    fi

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\refind\refind_x64.efi" > "/mnt$ESP_DIRECTORY/startup.nsh"
    fi
}

function systemd() {
    arch-chroot /mnt bootctl --path="$ESP_DIRECTORY" install

    arch-chroot /mnt mkdir -p "$ESP_DIRECTORY/loader/"
    arch-chroot /mnt mkdir -p "$ESP_DIRECTORY/loader/entries/"

    echo "# alis" > "/mnt$ESP_DIRECTORY/loader/loader.conf"
    echo "timeout 5" >> "/mnt$ESP_DIRECTORY/loader/loader.conf"
    echo "default archlinux" >> "/mnt$ESP_DIRECTORY/loader/loader.conf"
    echo "editor 0" >> "/mnt$ESP_DIRECTORY/loader/loader.conf"

    arch-chroot /mnt mkdir -p "/etc/pacman.d/hooks/"

    echo "[Trigger]" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "Type = Package" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "Operation = Upgrade" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "Target = systemd" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "[Action]" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "Description = Updating systemd-boot..." >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "When = PostTransaction" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook
    echo "Exec = /usr/bin/bootctl update" >> /mnt/etc/pacman.d/hooks/systemd-boot.hook

    SYSTEMD_MICROCODE=""
    SYSTEMD_OPTIONS=""

    if [ "$CPU_INTEL" == "true" -a "$VIRTUALBOX" != "true" ]; then
        SYSTEMD_MICROCODE="/intel-ucode.img"
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
       SYSTEMD_OPTIONS="rd.luks.options=discard"
    fi

    echo "title Arch Linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    echo "efi /vmlinuz-linux" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    fi
    echo "initrd /initramfs-linux.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
    echo "options initrd=initramfs-linux.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"

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
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
        fi
        echo "initrd /initramfs-linux-lts.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"
        echo "options initrd=initramfs-linux-lts.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-lts.conf"

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
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
        fi
        echo "initrd /initramfs-linux-hardened.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"
        echo "options initrd=initramfs-linux-hardened.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-hardened.conf"

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
            echo "initrd $SYSTEMD_MICROCODE" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux.conf"
        fi
        echo "initrd /initramfs-linux-zen.img" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"
        echo "options initrd=initramfs-linux-zen.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX $SYSTEMD_OPTIONS" >> "/mnt$ESP_DIRECTORY/loader/entries/archlinux-zen.conf"

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

function users() {
    create_user $USER_NAME $USER_PASSWORD

    for i in ${!ADDITIONAL_USER_NAMES_ARRAY[@]}; do
        create_user ${ADDITIONAL_USER_NAMES_ARRAY[$i]} ${ADDITIONAL_USER_PASSWORDS_ARRAY[$i]}
    done

	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
}

function create_user() {
    echo ""
    echo -e "${LIGHT_BLUE}# create_user() step${NC}"
    echo ""

    USER_NAME=$1
    USER_PASSWORD=$2
    arch-chroot /mnt useradd -m -G wheel,storage,optical -s /bin/bash $USER_NAME
    printf "$USER_PASSWORD\n$USER_PASSWORD" | arch-chroot /mnt passwd $USER_NAME

    pacman_install "xdg-user-dirs"
}

function desktop_environment() {
    echo ""
    echo -e "${LIGHT_BLUE}# desktop_environment() step${NC}"
    echo ""

    PACKAGES_DRIVER=""
    PACKAGES_DDX=""
    PACKAGES_VULKAN=""
    PACKAGES_HARDWARE_ACCELERATION=""
    case "$DISPLAY_DRIVER" in
        "nvidia" )
            PACKAGES_DRIVER="nvidia"
            ;;
        "nvidia-lts" )
            PACKAGES_DRIVER="nvidia-lts"
            ;;
        "nvidia-dkms" )
            PACKAGES_DRIVER="nvidia-dkms"
            ;;
        "nvidia-390xx" )
            PACKAGES_DRIVER="nvidia-390xx"
            ;;
        "nvidia-390xx-lts" )
            PACKAGES_DRIVER="nvidia-390xx-lts"
            ;;
        "nvidia-390xx-dkms" )
            PACKAGES_DRIVER="nvidia-390xx-dkms"
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
                ;;
            "amdgpu" )
                PACKAGES_VULKAN="vulkan-icd-loader vulkan-radeon"
                ;;
            "ati" )
                PACKAGES_VULKAN=""
                ;;
            "nouveau" )
                PACKAGES_VULKAN=""
                ;;
        esac
    fi
    if [ "$DISPLAY_DRIVER_HARDWARE_ACCELERATION" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                PACKAGES_HARDWARE_ACCELERATION="intel-media-driver"
                if [ -n "$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL" ]; then
                    PACKAGES_HARDWARE_ACCELERATION=$DISPLAY_DRIVER_HARDWARE_ACCELERATION_INTEL
                fi
                ;;
            "amdgpu" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                ;;
            "ati" )
                PACKAGES_HARDWARE_ACCELERATION="mesa-vdpau"
                ;;
            "nouveau" )
                PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                ;;
        esac
    fi
    pacman_install "mesa $PACKAGES_DRIVER $PACKAGES_DDX $PACKAGES_VULKAN $PACKAGES_HARDWARE_ACCELERATION"

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
    esac
}

function desktop_environment_gnome() {
    pacman_install "gnome gnome-extra"
    arch-chroot /mnt systemctl enable gdm.service
}

function desktop_environment_kde() {
    pacman_install "plasma-meta plasma-wayland-session kde-applications-meta"
    arch-chroot /mnt systemctl enable sddm.service
}

function desktop_environment_xfce() {
    pacman_install "xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_mate() {
    pacman_install "mate mate-extra lightdm lightdm-gtk-greeter"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_cinnamon() {
    pacman_install "cinnamon lightdm lightdm-gtk-greeter"
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_lxde() {
    pacman_install "lxde lxdm"
    arch-chroot /mnt systemctl enable lxdm.service
}

function packages() {
    echo ""
    echo -e "${LIGHT_BLUE}# packages() step${NC}"
    echo ""

    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        pacman_install "btrfs-progs"
    fi

    if [ -n "$PACKAGES_PACMAN" ]; then
        pacman_install "$PACKAGES_PACMAN"
    fi

    packages_aur
}

function packages_aur() {
    if [ -n "$AUR" -o -n "$PACKAGES_AUR" ]; then
        pacman_install "git"

        arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
        case "$AUR" in
            "aurman" )
                arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -c \"cd /home/$USER_NAME && git clone https://aur.archlinux.org/$AUR.git && gpg --recv-key 465022E743D71E39 && (cd $AUR && makepkg -si --noconfirm) && rm -rf $AUR\""
                ;;
            "yay" | *)
                arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -c \"cd /home/$USER_NAME && git clone https://aur.archlinux.org/$AUR.git && (cd $AUR && makepkg -si --noconfirm) && rm -rf $AUR\""
                ;;
        esac
        arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
    fi

    if [ -n "$PACKAGES_AUR" ]; then
        aur_install "$PACKAGES_AUR"
    fi
}

function terminate() {
    cp "$CONF_FILE" "/mnt/etc/$CONF_FILE"

    if [ "$LOG" == "true" ]; then
        mkdir -p /mnt/var/log
        cp "$LOG_FILE" "/mnt/var/log/$LOG_FILE"
    fi
    if [ "$ASCIINEMA" == "true" ]; then
        mkdir -p /mnt/var/log
        cp "$ASCIINEMA_FILE" "/mnt/var/log/$ASCIINEMA_FILE"
    fi
}

function end() {
    if [ "$REBOOT" == "true" ]; then
        echo ""
        echo -e "${GREEN}Arch Linux installed successfully"'!'"${NC}"
        echo ""

        REBOOT="true"
        if [ "$ASCIINEMA" == "false" ]; then
            set +e
            for (( i = 15; i >= 1; i-- )); do
                read -r -s -n 1 -t 1 -p "Rebooting in $i seconds... Press any key to abort."$'\n' KEY
                if [ $? -eq 0 ]; then
                    echo ""
                    echo "Restart aborted. You will must do a explicit reboot (./alis-reboot.sh)."
                    echo ""
                    REBOOT="false"
                    break
                fi
            done
            set -e
        else
            echo ""
            echo "Restart aborted. You will must terminate asciinema recording and do a explicit reboot (exit, ./alis-reboot.sh)."
            echo ""
            REBOOT="false"
        fi

        if [ "$REBOOT" == 'true' ]; then
            umount -R /mnt/boot
            umount -R /mnt
            reboot
        fi
    else
        echo ""
        echo -e "${GREEN}Arch Linux installed successfully"'!'"${NC}"
        if [ "$ASCIINEMA" == "false" ]; then
            echo ""
            echo "You will must do a explicit reboot (./alis-reboot.sh)."
            echo ""
        else
            echo ""
            echo "You will must terminate asciinema recording and do a explicit reboot (exit, ./alis-reboot.sh)."
            echo ""
        fi
    fi
}

function pacman_install() {
    PACKAGES=$1
    for VARIABLE in {1..5}
    do
        arch-chroot /mnt pacman -Syu --noconfirm --needed $PACKAGES
        if [ $? == 0 ]; then
            break
        else
            sleep 10
        fi
    done
}

function aur_install() {
    PACKAGES=$1
    for VARIABLE in {1..5}
    do
        arch-chroot /mnt bash -c "echo -e \"$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n$USER_PASSWORD\n\" | su $USER_NAME -c \"$AUR -Syu --noconfirm --needed $PACKAGES\""
        if [ $? == 0 ]; then
            break
        else
            sleep 10
        fi
    done
}

function main() {
    configuration_install
    sanitize_variables
    check_variables
    warning
    init
    facts
    check_facts
    prepare
    partition
    install
    kernels
    configuration
    network
    if [ "$VIRTUALBOX" == "true" ]; then
        virtualbox
    fi
    users
    mkinitcpio
    bootloader
    if [ "$DESKTOP_ENVIRONMENT" != "" ]; then
        desktop_environment
    fi
    packages
    terminate
    end
}

main
