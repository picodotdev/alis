#!/usr/bin/env bash
set -e

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
# Copyright (C) 2017 picodotdev

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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This script is hosted in https://github.com/picodotdev/alis. For new features,
# improvements and bugs fill an issue in GitHub or make a pull request.
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
# # wget -O alis.conf https://raw.githubusercontent.com/picodotdev/alis/master/alis.conf
# # vim alis.conf
# # wget -O alis.sh https://raw.githubusercontent.com/picodotdev/alis/master/alis.sh
# # chmod +x alis.sh
# # ./alis.sh

# alis variables (no configuration, don't edit)
BIOS_TYPE=""
PARTITION_BIOS=""
PARTITION_BOOT=""
PARTITION_ROOT=""
DEVICE_ROOT=""
DEVICE_ROOT_MAPPER=""
PARTITION_BOOT_NUMBER=0
UUID_BOOT=""
UUID_ROOT=""
DEVICE_TRIM=""
ALLOW_DISCARDS=""
CPU_INTEL=""
VIRTUALBOX=""
GRUB_CMDLINE_LINUX=""
ADDITIONAL_USER_NAMES_ARRAY=()
ADDITIONAL_USER_PASSWORDS_ARRAY=()
MODULES=""

RED='\033[0;31m'
NC='\033[0m'

function configuration_install() {
    source alis.conf
    ADDITIONAL_USER_NAMES_ARRAY=($ADDITIONAL_USER_NAMES)
    ADDITIONAL_USER_PASSWORDS_ARRAY=($ADDITIONAL_USER_PASSWORDS)
}

function check_variables() {
    check_variables_value "KEYS" "$KEYS"
    check_variables_value "DEVICE" "$DEVICE"
    check_variables_boolean "LVM" "$LVM"
    check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 btrfs xfs"
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_value "PACMAN_MIRROR" "$PACMAN_MIRROR"
    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALE" "$LOCALE"
    check_variables_value "LANG" "$LANG"
    check_variables_value "KEYMAP" "$KEYMAP"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_size "ADDITIONAL_USER_PASSWORDS" "${#ADDITIONAL_USER_NAMES_ARRAY[@]}" "${#ADDITIONAL_USER_PASSWORDS_ARRAY[@]}"
    check_variables_boolean "YAOURT" "$YAOURT"
    check_variables_list "DESKTOP_ENVIRONMENT" "$DESKTOP_ENVIRONMENT" "gnome kde xfce mate cinnamon lxde" "false"
    check_variables_list "DISPLAY_DRIVER" "$DISPLAY_DRIVER" "xf86-video-intel xf86-video-amdgpu xf86-video-ati nvidia nvidia-340xx nvidia-304xx xf86-video-nouveau" "false"
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
    echo "Welcome to Arch Linux Install Script"
    echo ""
    echo -e "${RED}Warning"'!'"${NC}"
    echo -e "${RED}This script deletes all partitions of the persistent${NC}"
    echo -e "${RED}storage and continuing all your data in it will be lost.${NC}"
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
	timedatectl set-ntp true
	configure_network
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
        echo "Network ping check failed. Cannot continue."
        exit
    fi
}

function partition() {
    sgdisk --zap-all $DEVICE
    wipefs -a $DEVICE

    if [ "$BIOS_TYPE" == "uefi" ]; then
        PARTITION_BOOT="/dev/sda1"
        PARTITION_ROOT="/dev/sda2"
        PARTITION_BOOT_NUMBER=1
        DEVICE_ROOT="/dev/sda2"
        DEVICE_ROOT_MAPPER="root"

        parted -s $DEVICE mklabel gpt mkpart primary fat32 1MiB 512MiB mkpart primary $FILE_SYSTEM_TYPE 512MiB 100% set 1 boot on
        sgdisk -t=1:ef00 $DEVICE
    fi

    if [ "$BIOS_TYPE" == "bios" ]; then
        PARTITION_BIOS="/dev/sda1"
        PARTITION_BOOT="/dev/sda2"
        PARTITION_ROOT="/dev/sda3"
        PARTITION_BOOT_NUMBER=2
        DEVICE_ROOT="/dev/sda3"
        DEVICE_ROOT_MAPPER="root"

        parted -s $DEVICE mklabel gpt mkpart primary fat32 1MiB 128MiB mkpart primary $FILE_SYSTEM_TYPE 128MiB 512MiB mkpart primary $FILE_SYSTEM_TYPE 512MiB 100% set 1 boot on
        sgdisk -t=1:ef02 $DEVICE
    fi

    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT_MAPPER="lvm"
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        echo -n $PARTITION_ROOT_ENCRYPTION_PASSWORD | cryptsetup --key-size=512 --key-file=- luksFormat $PARTITION_ROOT
        echo -n $PARTITION_ROOT_ENCRYPTION_PASSWORD | cryptsetup --key-file=- open $PARTITION_ROOT $DEVICE_ROOT_MAPPER

        DEVICE_ROOT="/dev/mapper/$DEVICE_ROOT_MAPPER"
    fi

    if [ "$LVM" == "true" ]; then
        pvcreate /dev/mapper/$DEVICE_ROOT_MAPPER
        vgcreate lvm /dev/mapper/$DEVICE_ROOT_MAPPER
        lvcreate -l 100%FREE -n lvroot $DEVICE_ROOT_MAPPER

        DEVICE_ROOT_MAPPER="lvm-lvroot"
        DEVICE_ROOT="/dev/mapper/$DEVICE_ROOT_MAPPER"
    fi

    if [ "$BIOS_TYPE" == "uefi" ]; then
        wipefs -a $PARTITION_BOOT
        mkfs.fat -n ESP -F32 $PARTITION_BOOT
        if [ "$FILE_SYSTEM_TYPE" == "ext4" ]; then
            wipefs -a $DEVICE_ROOT
            mkfs."$FILE_SYSTEM_TYPE" -L root -E discard $DEVICE_ROOT
        else
            wipefs -a $DEVICE_ROOT
            mkfs."$FILE_SYSTEM_TYPE" -L root $DEVICE_ROOT
        fi
    fi

    if [ "$BIOS_TYPE" == "bios" ]; then
        wipefs -a $PARTITION_BIOS
        mkfs.fat -n BIOS -F32 $PARTITION_BIOS
        if [ "$FILE_SYSTEM_TYPE" == "ext4" ]; then
            wipefs -a $PARTITION_BOOT
            wipefs -a $DEVICE_ROOT
            mkfs."$FILE_SYSTEM_TYPE" -L boot -E discard $PARTITION_BOOT
            mkfs."$FILE_SYSTEM_TYPE" -L root -E discard $DEVICE_ROOT
        elif [ "$FILE_SYSTEM_TYPE" == "xfs" ]; then
            wipefs -a $PARTITION_BOOT
            wipefs -a $DEVICE_ROOT
            mkfs."$FILE_SYSTEM_TYPE" -L boot -f $PARTITION_BOOT
            mkfs."$FILE_SYSTEM_TYPE" -L root -f $DEVICE_ROOT
        else
            wipefs -a $PARTITION_BOOT
            wipefs -a $DEVICE_ROOT
            mkfs."$FILE_SYSTEM_TYPE" -L boot $PARTITION_BOOT
            mkfs."$FILE_SYSTEM_TYPE" -L root $DEVICE_ROOT
        fi
    fi

    mount $DEVICE_ROOT /mnt

    mkdir /mnt/boot
    mount $PARTITION_BOOT /mnt/boot

    if [ -n "$SWAP_SIZE" -a "$FILE_SYSTEM_TYPE" != "btrfs" ]; then
        fallocate -l $SWAP_SIZE /mnt/swap
        chmod 600 /mnt/swap
        mkswap /mnt/swap
    fi

    UUID_BOOT=$(blkid -s UUID -o value $PARTITION_BOOT)
    UUID_ROOT=$(blkid -s UUID -o value $PARTITION_ROOT)
}

function install() {
    echo $PACMAN_MIRROR >> /etc/pacman.d/mirrrorlist
    pacstrap /mnt base base-devel
}

function kernels() {
    arch-chroot /mnt pacman -Sy --noconfirm linux-headers
    if [ -n "$KERNELS" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm $KERNELS
    fi
}

function configuration() {
    genfstab -U /mnt >> /mnt/etc/fstab

    if [ "$DEVICE_TRIM" == "true" ]; then
        sed -i 's/relatime/noatime,discard/' /mnt/etc/fstab
        sed -i 's/issue_discards = 0/issue_discards = 1/' /mnt/etc/lvm/lvm.conf
    fi

    if [ -n "$SWAP_SIZE" -a "$FILE_SYSTEM_TYPE" != "btrfs" ]; then
        echo "# swap" >> /mnt/etc/fstab
        echo "/swap none swap defaults 0 0" >> /mnt/etc/fstab
        echo "" >> /mnt/etc/fstab
    fi

    arch-chroot /mnt ln -s -f $TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    sed -i "s/#$LOCALE/$LOCALE/" /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo $LANG > /mnt/etc/locale.conf
    echo $KEYMAP > /mnt/etc/vconsole.conf
    echo $HOSTNAME > /mnt/etc/hostname

    if [ -n "$SWAP_SIZE" ]; then
        echo "vm.swappiness=10" > /mnt/etc/sysctl.d/99-sysctl.conf
    fi

    printf "$ROOT_PASSWORD\n$ROOT_PASSWORD" | arch-chroot /mnt passwd
}

function network() {
    arch-chroot /mnt pacman -Sy --noconfirm networkmanager
    arch-chroot /mnt systemctl enable NetworkManager.service
}

function virtualbox() {
    if [ -z "$KERNELS" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm virtualbox-guest-utils virtualbox-guest-modules-arch
    else
        arch-chroot /mnt pacman -Sy --noconfirm virtualbox-guest-utils virtualbox-guest-dkms
    fi
}

function mkinitcpio() {
    if [ "$DISPLAY_DRIVER" == "xf86-video-intel" ]; then
        MODULES="i915"
    elif [ "$DISPLAY_DRIVER" == "xf86-video-amdgpu" ]; then
        MODULES="amdgpu"
    elif [ "$DISPLAY_DRIVER" == "xf86-video-ati" ]; then
        MODULES="radeon"
    elif [ "$DISPLAY_DRIVER" == "xf86-video-nouveau" ]; then
        MODULES="nouveau"
    fi
    arch-chroot /mnt sed -i "s/MODULES=()/MODULES=($MODULES)/" /etc/mkinitcpio.conf

    if [ "$LVM" == "true" -a -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        arch-chroot /mnt sed -i 's/ filesystems / lvm2 encrypt keymap filesystems /' /etc/mkinitcpio.conf
    elif [ "$LVM" == "true" ]; then
        arch-chroot /mnt sed -i 's/ filesystems / lvm2 filesystems /' /etc/mkinitcpio.conf
    elif [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        arch-chroot /mnt sed -i 's/ filesystems / encrypt keymap filesystems /' /etc/mkinitcpio.conf
    fi

    if [ "$KERNELS_COMPRESSION" != "" ]; then
        arch-chroot /mnt sed -i "s/#COMPRESSION=\"$KERNELS_COMPRESSION\"/COMPRESSION=\"$KERNELS_COMPRESSION\"/" /etc/mkinitcpio.conf
    fi

    arch-chroot /mnt mkinitcpio -P
}

function bootloader() {
    if [ "$CPU_INTEL" == "true" -a "$VIRTUALBOX" != "true" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm intel-ucode
    fi

    if [ -n "$PARTITION_ROOT_ENCRYPTION_PASSWORD" ]; then
        if [ "$DEVICE_TRIM" == "true" ]; then
            ALLOW_DISCARDS=":allow-discards"
        fi

        GRUB_CMDLINE_LINUX="cryptdevice=UUID='"$UUID_ROOT"':lvm'"$ALLOW_DISCARDS"'"
    fi

    arch-chroot /mnt pacman -Sy --noconfirm grub dosfstools
    #arch-chroot /mnt sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
    #arch-chroot /mnt sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
    arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
    arch-chroot /mnt sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="'$GRUB_CMDLINE_LINUX'"/' /etc/default/grub
	#arch-chroot /mnt echo "" >> /etc/default/grub
	#arch-chroot /mnt echo "# Custom alis" >> /etc/default/grub
	#arch-chroot /mnt echo GRUB_DISABLE_SUBMENU=y >> /etc/default/grub

    if [ "$BIOS_TYPE" == "uefi" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm efibootmgr
        arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot --recheck
        #arch-chroot /mnt efibootmgr --create --disk $DEVICE --part $PARTITION_BOOT_NUMBER --loader /EFI/grub/grubx64.efi --label "GRUB Boot Manager"
    fi
    if [ "$BIOS_TYPE" == "bios" ]; then
        arch-chroot /mnt grub-install --target=i386-pc --recheck $DEVICE
    fi

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\grub\grubx64.efi" > /mnt/boot/startup.nsh
    fi

    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

function users() {
    create_user $USER_NAME $USER_PASSWORD

    for i in ${!ADDITIONAL_USER_NAMES_ARRAY[@]}; do
        create_user ${ADDITIONAL_USER_NAMES_ARRAY[$i]} ${ADDITIONAL_USER_PASSWORDS_ARRAY[$i]}
    done

	arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
}

function create_user() {
	USER_NAME=$1
	USER_PASSWORD=$2
    arch-chroot /mnt useradd -m -G wheel,storage,optical -s /bin/bash $USER_NAME
    printf "$USER_PASSWORD\n$USER_PASSWORD" | arch-chroot /mnt passwd $USER_NAME
}

function desktop_environment() {
    case "$DISPLAY_DRIVER" in
        "xf86-video-intel" )
            MESA_LIBGL="mesa-libgl"
            ;;
        "xf86-video-ati" )
            MESA_LIBGL="mesa-libgl"
            ;;
        "xf86-video-amdgpu" )
            MESA_LIBGL="mesa-libgl"
            ;;
        "xf86-video-nouveau" )
            MESA_LIBGL="mesa-libgl"
            ;;
         "nvidia" )
            MESA_LIBGL="nvidia-libgl"
            ;;
        "nvidia-340xx" )
            MESA_LIBGL="nvidia-340xx-libgl"
            ;;
        "nvidia-304xx" )
            MESA_LIBGL="nvidia-304xx-libgl"
            ;;
        * )
            MESA_LIBGL="mesa-libgl"
            ;;
    esac

    arch-chroot /mnt pacman -Sy --noconfirm xorg-server xorg-apps $DISPLAY_DRIVER mesa $MESA_LIBGL

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
    arch-chroot /mnt pacman -Sy --noconfirm gnome gnome-extra
    arch-chroot /mnt systemctl enable gdm.service
}

function desktop_environment_kde() {
    arch-chroot /mnt pacman -Sy --noconfirm plasma-meta kde-applications-meta
    arch-chroot /mnt sed -i 's/Current=.*/Current=breeze/' /etc/sddm.conf
    arch-chroot /mnt systemctl enable sddm.service
}

function desktop_environment_xfce() {
    arch-chroot /mnt pacman -Sy --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_mate() {
    arch-chroot /mnt pacman -Sy --noconfirm mate mate-extra lightdm lightdm-gtk-greeter
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_cinnamon() {
    arch-chroot /mnt pacman -Sy --noconfirm cinnamon lightdm lightdm-gtk-greeter
    arch-chroot /mnt systemctl enable lightdm.service
}

function desktop_environment_lxde() {
    arch-chroot /mnt pacman -Sy --noconfirm lxde lxdm
    arch-chroot /mnt systemctl enable lxdm.service
}

function packages() {
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm btrfs-progs
    fi

    if [ "$YAOURT" == "true" -o -n "$PACKAGES_YAOURT" ]; then
        echo "" >> /mnt/etc/pacman.conf
        echo "[archlinuxfr]" >> /mnt/etc/pacman.conf
        echo "SigLevel=Optional TrustAll" >> /mnt/etc/pacman.conf
        echo "Server=http://repo.archlinux.fr/\$arch" >> /mnt/etc/pacman.conf

        arch-chroot /mnt pacman -Sy --noconfirm yaourt
    fi

    if [ -n "$PACKAGES_PACMAN" ]; then
        arch-chroot /mnt pacman -Sy --noconfirm --needed $PACKAGES_PACMAN
    fi

    if [ -n "$PACKAGES_YAOURT" ]; then
        arch-chroot /mnt yaourt -S --noconfirm --needed $PACKAGES_YAOURT
    fi
}

function end() {
    umount -R /mnt
    reboot
}

function main() {
    configuration_install
    check_variables
    warning
    init
    facts
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
    if [ "$REBOOT" == "true" ]; then
        end
    fi
}

main
