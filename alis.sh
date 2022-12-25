#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2153,SC2034,SC2155,SC2181
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC2034: foo appears unused. Verify it or export it.
# SC2155 Declare and assign separately to avoid masking return values
# SC2153: Possible Misspelling: MYVARIABLE may not be assigned. Did you mean MY_VARIABLE?
# SC2181: Check exit code directly with e.g. if mycmd;, not indirectly with $?.

set -eu

# Arch Linux Install Script (alis) installs unattended, automated
# and customized Arch Linux system.
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

# Script to install an Arch Linux system.
#
# Usage:
# # loadkeys es
# # curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
# # vim alis.conf
# # ./alis.sh

function init_config() {
    local COMMONS_FILE="alis-commons.sh"

    source "$COMMONS_FILE" #SC1090
    source "$COMMONS_CONF_FILE"
    source "$ALIS_CONF_FILE"
}

function sanitize_variables() {
    DEVICE=$(sanitize_variable "$DEVICE")
    PARTITION_MODE=$(sanitize_variable "$PARTITION_MODE")
    PARTITION_CUSTOM_PARTED_UEFI=$(sanitize_variable "$PARTITION_CUSTOM_PARTED_UEFI")
    PARTITION_CUSTOM_PARTED_BIOS=$(sanitize_variable "$PARTITION_CUSTOM_PARTED_BIOS")
    FILE_SYSTEM_TYPE=$(sanitize_variable "$FILE_SYSTEM_TYPE")
    SWAP_SIZE=$(sanitize_variable "$SWAP_SIZE")
    KERNELS=$(sanitize_variable "$KERNELS")
    KERNELS_COMPRESSION=$(sanitize_variable "$KERNELS_COMPRESSION")
    KERNELS_PARAMETERS=$(sanitize_variable "$KERNELS_PARAMETERS")
    AUR_PACKAGE=$(sanitize_variable "$AUR_PACKAGE")
    DISPLAY_DRIVER=$(sanitize_variable "$DISPLAY_DRIVER")
    DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL=$(sanitize_variable "$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL")
    SYSTEMD_HOMED_STORAGE=$(sanitize_variable "$SYSTEMD_HOMED_STORAGE")
    SYSTEMD_HOMED_STORAGE_LUKS_TYPE=$(sanitize_variable "$SYSTEMD_HOMED_STORAGE_LUKS_TYPE")
    BOOTLOADER=$(sanitize_variable "$BOOTLOADER")
    CUSTOM_SHELL=$(sanitize_variable "$CUSTOM_SHELL")
    DESKTOP_ENVIRONMENT=$(sanitize_variable "$DESKTOP_ENVIRONMENT")
    DISPLAY_MANAGER=$(sanitize_variable "$DISPLAY_MANAGER")
    SYSTEMD_UNITS=$(sanitize_variable "$SYSTEMD_UNITS")

    for I in "${BTRFS_SUBVOLUMES_MOUNTPOINTS[@]}"; do
        IFS=',' read -ra SUBVOLUME <<< "$I"
        if [ "${SUBVOLUME[0]}" == "root" ]; then
            BTRFS_SUBVOLUME_ROOT=("${SUBVOLUME[@]}")
        elif [ "${SUBVOLUME[0]}" == "swap" ]; then
            BTRFS_SUBVOLUME_SWAP=("${SUBVOLUME[@]}")
        fi
    done

    for I in "${PARTITION_MOUNT_POINTS[@]}"; do #SC2153
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
        local DEVICE_BOOT=$(lsblk -oMOUNTPOINT,PKNAME -P -M | grep 'MOUNTPOINT="/run/archiso/bootmnt"' | sed 's/.*PKNAME="\(.*\)".*/\1/') #SC2155
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
    check_variables_equals "WIFI_KEY" "WIFI_KEY_RETYPE" "$WIFI_KEY" "$WIFI_KEY_RETYPE"
    check_variables_value "PING_HOSTNAME" "$PING_HOSTNAME"
    check_variables_boolean "REFLECTOR" "$REFLECTOR"
    check_variables_value "PACMAN_MIRROR" "$PACMAN_MIRROR"
    check_variables_boolean "PACMAN_PARALLEL_DOWNLOADS" "$PACMAN_PARALLEL_DOWNLOADS"
    check_variables_list "KERNELS" "$KERNELS" "linux-lts linux-lts-headers linux-hardened linux-hardened-headers linux-zen linux-zen-headers" "false" "false"
    check_variables_list "KERNELS_COMPRESSION" "$KERNELS_COMPRESSION" "gzip bzip2 lzma xz lzop lz4 zstd" "false" "true"
    check_variables_list "AUR_PACKAGE" "$AUR_PACKAGE" "paru-bin yay-bin paru yay aurman" "true" "true"
    check_variables_list "DISPLAY_DRIVER" "$DISPLAY_DRIVER" "auto intel amdgpu ati nvidia nvidia-lts nvidia-dkms nvidia-470xx-dkms nvidia-390xx-dkms nvidia-340xx-dkms nouveau" "false" "true"
    check_variables_boolean "KMS" "$KMS"
    check_variables_boolean "FASTBOOT" "$FASTBOOT"
    check_variables_boolean "FRAMEBUFFER_COMPRESSION" "$FRAMEBUFFER_COMPRESSION"
    check_variables_boolean "DISPLAY_DRIVER_DDX" "$DISPLAY_DRIVER_DDX"
    check_variables_boolean "DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION" "$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION"
    check_variables_list "DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL" "$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL" "intel-media-driver libva-intel-driver" "false" "true"
    check_variables_value "TIMEZONE" "$TIMEZONE"
    check_variables_value "LOCALES" "$LOCALES"
    check_variables_value "LOCALE_CONF" "$LOCALE_CONF"
    check_variables_value "KEYMAP" "$KEYMAP"
    check_variables_value "HOSTNAME" "$HOSTNAME"
    check_variables_value "USER_NAME" "$USER_NAME"
    check_variables_value "USER_PASSWORD" "$USER_PASSWORD"
    check_variables_equals "ROOT_PASSWORD" "ROOT_PASSWORD_RETYPE" "$ROOT_PASSWORD" "$ROOT_PASSWORD_RETYPE"
    check_variables_equals "USER_PASSWORD" "USER_PASSWORD_RETYPE" "$USER_PASSWORD" "$USER_PASSWORD_RETYPE"
    check_variables_boolean "SYSTEMD_HOMED" "$SYSTEMD_HOMED"
    check_variables_list "SYSTEMD_HOMED_STORAGE" "$SYSTEMD_HOMED_STORAGE" "auto luks subvolume directory fscrypt cifs" "true" "true"
    check_variables_list "SYSTEMD_HOMED_STORAGE_LUKS_TYPE" "$SYSTEMD_HOMED_STORAGE_LUKS_TYPE" "auto ext4 btrfs xfs" "true" "true"
    if [ "$SYSTEMD_HOMED" == "true" ]; then
        if [ "$SYSTEMD_HOMED_STORAGE" == "fscrypt" ]; then
            check_variables_list "FILE_SYSTEM_TYPE" "$FILE_SYSTEM_TYPE" "ext4 f2fs" "true" "true"
        fi
        if [ "$SYSTEMD_HOMED_STORAGE" == "cifs" ]; then
            check_variables_value "SYSTEMD_HOMED_CIFS[\"domain]\"" "${SYSTEMD_HOMED_CIFS_DOMAIN["domain"]}"
            check_variables_value "SYSTEMD_HOMED_CIFS[\"service\"]" "${SYSTEMD_HOMED_CIFS_SERVICE["size"]}"
        fi
    fi
    check_variables_value "HOOKS" "$HOOKS"
    check_variables_list "BOOTLOADER" "$BOOTLOADER" "auto grub refind systemd" "true" "true"
    check_variables_list "CUSTOM_SHELL" "$CUSTOM_SHELL" "bash zsh dash fish" "true" "true"
    check_variables_list "DESKTOP_ENVIRONMENT" "$DESKTOP_ENVIRONMENT" "gnome kde xfce mate cinnamon lxde i3-wm i3-gaps deepin budgie bspwm awesome qtile openbox leftwm dusk" "false" "true"
    check_variables_list "DISPLAY_MANAGER" "$DISPLAY_MANAGER" "auto gdm sddm lightdm lxdm" "true" "true"
    check_variables_boolean "PACKAGES_MULTILIB" "$PACKAGES_MULTILIB"
    check_variables_boolean "PACKAGES_INSTALL" "$PACKAGES_INSTALL"
    check_variables_boolean "PROVISION" "$PROVISION"
    check_variables_boolean "VAGRANT" "$VAGRANT"
    check_variables_boolean "REBOOT" "$REBOOT"
}

function warning() {
    echo -e "${BLUE}Welcome to Arch Linux Install Script${NC}"
    echo ""
    echo -e "${RED}Warning"'!'"${NC}"
    echo -e "${RED}This script can delete all partitions of the persistent${NC}"
    echo -e "${RED}storage and continuing all your data can be lost.${NC}"
    echo ""
    echo -e "Install device: $DEVICE."
    echo -e "Mount points: ${PARTITION_MOUNT_POINTS[*]}."
    echo ""
    if [ "$WARNING_CONFIRM" == "true" ]; then
        read -r -p "Do you want to continue? [y/N] " yn
    else
        yn="y"
        sleep 2
    fi
    case $yn in
        [Yy]* )
            ;;
        [Nn]* )
            exit 0
            ;;
        * )
            exit 0
            ;;
    esac
}

function init() {
    print_step "init()"

    init_log_trace "$LOG_TRACE"
    init_log_file "$LOG_FILE" "$ALIS_LOG_FILE"
    loadkeys "$KEYS"
}

function facts() {
    print_step "facts()"

    facts_commons

    if echo "$DEVICE" | grep -q "^/dev/sd[a-z]"; then
        DEVICE_SDA="true" #SC2034
    elif echo "$DEVICE" | grep -q "^/dev/nvme"; then
        DEVICE_NVME="true"
    elif echo "$DEVICE" | grep -q "^/dev/vd[a-z]"; then
        DEVICE_VDA="true"
    elif echo "$DEVICE" | grep -q "^/dev/mmc"; then
        DEVICE_MMC="true"
    fi

    if [ "$DISPLAY_DRIVER" == "auto" ]; then
        case "$GPU_VENDOR" in
            "intel" )
                DISPLAY_DRIVER="intel"
                ;;
            "amd" )
                DISPLAY_DRIVER="amdgpu"
                ;;
            "nvidia" )
                DISPLAY_DRIVER="nvidia"
                ;;
        esac
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

    if [ "$BOOTLOADER" == "auto" ]; then
        if [ "$BIOS_TYPE" == "uefi" ]; then
            BOOTLOADER="systemd"
        elif [ "$BIOS_TYPE" == "bios" ]; then
            BOOTLOADER="grub"
        fi
    fi
}

function checks() {
    print_step "checks()"

    check_facts
}

function check_facts() {
    if [ "$BIOS_TYPE" == "bios" ]; then
        check_variables_list "BOOTLOADER" "$BOOTLOADER" "grub" "true" "true"
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
        if systemctl is-active --quiet reflector.service; then
            systemctl stop reflector.service
        fi
    fi
}

function configure_time() {
    timedatectl set-ntp true
}

function prepare_partition() {
    set +e
    if mountpoint -q "${MNT_DIR}"/boot; then
        umount "${MNT_DIR}"/boot
    fi
    if mountpoint -q "${MNT_DIR}"; then
        umount "${MNT_DIR}"
    fi
    if lvs "$LVM_VOLUME_GROUP"-"$LVM_VOLUME_LOGICAL"; then
        lvchange -an "$LVM_VOLUME_GROUP/$LVM_VOLUME_LOGICAL"
    fi
    if vgs "$LVM_VOLUME_GROUP"; then
        vgchange -an "$LVM_VOLUME_GROUP"
    fi
    if [ -e "/dev/mapper/$LUKS_DEVICE_NAME" ]; then
        if cryptsetup status "$LUKS_DEVICE_NAME "| grep -qi "is active"; then
            cryptsetup close "$LUKS_DEVICE_NAME"
        fi
    fi
    set -e
}

function ask_passwords() {
    if [ "$LUKS_PASSWORD" == "ask" ]; then
        ask_password "LUKS" "LUKS_PASSWORD"
    fi

    if [ -n "$WIFI_INTERFACE" ] && [ "$WIFI_KEY" == "ask" ]; then
        ask_password "WIFI" "WIFI_KEY"
    fi

    if [ "$ROOT_PASSWORD" == "ask" ]; then
        ask_password "root" "ROOT_PASSWORD"
    fi

    if [ "$USER_PASSWORD" == "ask" ]; then
        ask_password "user" "USER_PASSWORD"
    fi

    for I in "${!ADDITIONAL_USERS[@]}"; do
        local VALUE=${ADDITIONAL_USERS[$I]}
        local S=()
        IFS='=' read -ra S <<< "$VALUE"
        local USER=${S[0]}
        local PASSWORD=${S[1]}
        local PASSWORD_RETYPE=""

        if [ "$PASSWORD" == "ask" ]; then
            local PASSWORD_TYPED="false"
            while [ "$PASSWORD_TYPED" != "true" ]; do
                read -r -sp "Type user ($USER) password: " PASSWORD
                echo ""
                read -r -sp "Retype user ($USER) password: " PASSWORD_RETYPE
                echo ""
                if [ "$PASSWORD" == "$PASSWORD_RETYPE" ]; then
                    local PASSWORD_TYPED="true"
                    ADDITIONAL_USERS[I]="$USER=$PASSWORD"
                else
                    echo "User ($USER) password don't match. Please, type again."
                fi
            done
        fi
    done
}

function partition() {
    print_step "partition()"

    partprobe -s "$DEVICE"

    # setup
    partition_setup

    # partition
    if [ "$PARTITION_MODE" == "auto" ]; then
        sgdisk --zap-all "$DEVICE"
        sgdisk -o "$DEVICE"
        wipefs -a -f "$DEVICE"
        partprobe -s "$DEVICE"
    fi
    if [ "$PARTITION_MODE" == "auto" ] || [ "$PARTITION_MODE" == "custom" ]; then
        if [ "$BIOS_TYPE" == "uefi" ]; then
            parted -s "$DEVICE" "$PARTITION_PARTED_UEFI"
            if [ -n "$LUKS_PASSWORD" ]; then
                sgdisk -t="$PARTITION_ROOT_NUMBER":8309 "$DEVICE"
            elif [ "$LVM" == "true" ]; then
                sgdisk -t="$PARTITION_ROOT_NUMBER":8e00 "$DEVICE"
            fi
        fi

        if [ "$BIOS_TYPE" == "bios" ]; then
            parted -s "$DEVICE" "$PARTITION_PARTED_BIOS"
        fi

        partprobe -s "$DEVICE"
    fi

    # luks and lvm
    if [ -n "$LUKS_PASSWORD" ]; then
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-size=512 --key-file=- luksFormat --type luks2 "$PARTITION_ROOT"
        echo -n "$LUKS_PASSWORD" | cryptsetup --key-file=- open "$PARTITION_ROOT" "$LUKS_DEVICE_NAME"
        sleep 5
    fi

    if [ "$LVM" == "true" ]; then
        if [ -n "$LUKS_PASSWORD" ]; then
            DEVICE_LVM="/dev/mapper/$LUKS_DEVICE_NAME"
        else
            DEVICE_LVM="$DEVICE_ROOT"
        fi

        if [ "$PARTITION_MODE" == "auto" ]; then
            set +e
            if lvs "$LVM_VOLUME_GROUP"-"$LVM_VOLUME_LOGICAL"; then
                lvremove -y "$LVM_VOLUME_GROUP"/"$LVM_VOLUME_LOGICAL"
            fi
            if vgs "$LVM_VOLUME_GROUP"; then
                vgremove -y "$LVM_VOLUME_GROUP"
            fi
            if pvs "$DEVICE_LVM"; then
                pvremove -y "$DEVICE_LVM"
            fi
            set -e

            pvcreate -y "$DEVICE_LVM"
            vgcreate -y "$LVM_VOLUME_GROUP" "$DEVICE_LVM"
            lvcreate -y -l 100%FREE -n "$LVM_VOLUME_LOGICAL" "$LVM_VOLUME_GROUP"
        fi
    fi

    if [ -n "$LUKS_PASSWORD" ]; then
        DEVICE_ROOT="/dev/mapper/$LUKS_DEVICE_NAME"
    fi
    if [ "$LVM" == "true" ]; then
        DEVICE_ROOT="/dev/mapper/$LVM_VOLUME_GROUP-$LVM_VOLUME_LOGICAL"
    fi

    # format
    if [ "$PARTITION_MODE" != "manual" ]; then
        # Delete patition filesystem in case is reinstalling in an already existing system
        # Not fail on error
        wipefs -a -f "$PARTITION_BOOT" || true
        wipefs -a -f "$DEVICE_ROOT" || true

        ## boot
        if [ "$BIOS_TYPE" == "uefi" ]; then
            mkfs.fat -n ESP -F32 "$PARTITION_BOOT"
        fi
        if [ "$BIOS_TYPE" == "bios" ]; then
            mkfs.ext4 -L boot "$PARTITION_BOOT"
        fi
        ## root
        if [ "$FILE_SYSTEM_TYPE" == "reiserfs" ]; then
            mkfs."$FILE_SYSTEM_TYPE" -f -l root "$DEVICE_ROOT"
        elif [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
            mkfs."$FILE_SYSTEM_TYPE" -l root "$DEVICE_ROOT"
        else
            mkfs."$FILE_SYSTEM_TYPE" -L root "$DEVICE_ROOT"
        fi
        ## mountpoint
        for I in "${PARTITION_MOUNT_POINTS[@]}"; do
            if [[ "$I" =~ ^!.* ]]; then
                continue
            fi
            IFS='=' read -ra PARTITION_MOUNT_POINT <<< "$I"
            if [ "${PARTITION_MOUNT_POINT[1]}" == "/boot" ] || [ "${PARTITION_MOUNT_POINT[1]}" == "/" ]; then
                continue
            fi
            local PARTITION_DEVICE="$(partition_device "$DEVICE" "${PARTITION_MOUNT_POINT[0]}")"
            if [ "$FILE_SYSTEM_TYPE" == "reiserfs" ]; then
                mkfs."$FILE_SYSTEM_TYPE" -f "$PARTITION_DEVICE"
            elif [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
                mkfs."$FILE_SYSTEM_TYPE" "$PARTITION_DEVICE"
            else
                mkfs."$FILE_SYSTEM_TYPE" "$PARTITION_DEVICE"
            fi
        done
    fi

    # options
    partition_options

    # create
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        # create subvolumes
        mount -o "$PARTITION_OPTIONS" "$DEVICE_ROOT" "${MNT_DIR}"
        for I in "${BTRFS_SUBVOLUMES_MOUNTPOINTS[@]}"; do
            IFS=',' read -ra SUBVOLUME <<< "$I"
            if [ "${SUBVOLUME[0]}" == "swap" ] && [ -z "$SWAP_SIZE" ]; then
                continue
            fi
            btrfs subvolume create "${MNT_DIR}/${SUBVOLUME[1]}"
        done
        umount "${MNT_DIR}"
    fi

    # mount
    partition_mount

    # swap
    if [ -n "$SWAP_SIZE" ]; then
        if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
            SWAPFILE="${BTRFS_SUBVOLUME_SWAP[2]}$SWAPFILE"
            chattr +C "${MNT_DIR}"
        fi

        dd if=/dev/zero of="${MNT_DIR}$SWAPFILE" bs=1M count="$SWAP_SIZE" status=progress
        chmod 600 "${MNT_DIR}${SWAPFILE}"
        mkswap "${MNT_DIR}${SWAPFILE}"
    fi

    # set variables
    BOOT_DIRECTORY=/boot
    ESP_DIRECTORY=/boot
    UUID_BOOT=$(blkid -s UUID -o value "$PARTITION_BOOT")
    UUID_ROOT=$(blkid -s UUID -o value "$PARTITION_ROOT")
    PARTUUID_BOOT=$(blkid -s PARTUUID -o value "$PARTITION_BOOT")
    PARTUUID_ROOT=$(blkid -s PARTUUID -o value "$PARTITION_ROOT")
}

function install() {
    print_step "install()"
    local COUNTRIES=()

    pacman-key --init
    pacman-key --populate

    if [ -n "$PACMAN_MIRROR" ]; then
        echo "Server = $PACMAN_MIRROR" > /etc/pacman.d/mirrorlist
    fi
    if [ "$REFLECTOR" == "true" ]; then
        for COUNTRY in "${REFLECTOR_COUNTRIES[@]}"; do
            local COUNTRIES+=(--country "$COUNTRY")
        done
        pacman -Sy --noconfirm reflector
        reflector "${COUNTRIES[@]}" --latest 25 --age 24 --protocol https --completion-percent 100 --sort rate --save /etc/pacman.d/mirrorlist
    fi

    sed -i 's/#Color/Color/' /etc/pacman.conf
    if [ "$PACMAN_PARALLEL_DOWNLOADS" == "true" ]; then
        sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    else
        sed -i 's/#ParallelDownloads\(.*\)/#ParallelDownloads\1\nDisableDownloadTimeout/' /etc/pacman.conf
    fi

    local PACKAGES=()
    if [ "$LVM" == "true" ]; then
        local PACKAGES+=("lvm2")
    fi
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        local PACKAGES+=("btrfs-progs")
    fi
    if [ "$FILE_SYSTEM_TYPE" == "xfs" ]; then
        local PACKAGES+=("xfsprogs")
    fi
    if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
        local PACKAGES+=("f2fs-tools")
    fi
    if [ "$FILE_SYSTEM_TYPE" == "reiserfs" ]; then
        local PACKAGES+=("reiserfsprogs")
    fi

    pacstrap "${MNT_DIR}" base base-devel linux linux-firmware "${PACKAGES[@]}"

    sed -i 's/#Color/Color/' "${MNT_DIR}"/etc/pacman.conf
    if [ "$PACMAN_PARALLEL_DOWNLOADS" == "true" ]; then
        sed -i 's/#ParallelDownloads/ParallelDownloads/' "${MNT_DIR}"/etc/pacman.conf
    else
        sed -i 's/#ParallelDownloads\(.*\)/#ParallelDownloads\1\nDisableDownloadTimeout/' "${MNT_DIR}"/etc/pacman.conf
    fi

    if [ "$REFLECTOR" == "true" ]; then
        pacman_install "reflector"
        cat <<EOT > "${MNT_DIR}/etc/xdg/reflector/reflector.conf"
${COUNTRIES[@]}
--latest 25
--age 24
--protocol https
--completion-percent 100
--sort rate
--save /etc/pacman.d/mirrorlist
EOT
        arch-chroot "${MNT_DIR}" reflector "${COUNTRIES[@]}" --latest 25 --age 24 --protocol https --completion-percent 100 --sort rate --save /etc/pacman.d/mirrorlist
        arch-chroot "${MNT_DIR}" systemctl enable reflector.timer
    fi

    if [ "$PACKAGES_MULTILIB" == "true" ]; then
        sed -z -i 's/#\[multilib\]\n#/[multilib]\n/' "${MNT_DIR}"/etc/pacman.conf
    fi
}

function configuration() {
    print_step "configuration()"

    genfstab -U "${MNT_DIR}" >> "${MNT_DIR}"/etc/fstab

    if [ -n "$SWAP_SIZE" ]; then
        {
            echo "# swap"
            echo "$SWAPFILE none swap defaults 0 0"
            echo "" 
        }>> "${MNT_DIR}"/etc/fstab
    fi

    if [ "$DEVICE_TRIM" == "true" ]; then
        if [ "$FILE_SYSTEM_TYPE" == "f2fs" ]; then
            sed -i 's/relatime/noatime,nodiscard/' "${MNT_DIR}"/etc/fstab
        else
            sed -i 's/relatime/noatime/' "${MNT_DIR}"/etc/fstab
        fi
        arch-chroot "${MNT_DIR}" systemctl enable fstrim.timer
    fi

    arch-chroot "${MNT_DIR}" ln -s -f "$TIMEZONE" /etc/localtime
    arch-chroot "${MNT_DIR}" hwclock --systohc
    for LOCALE in "${LOCALES[@]}"; do
        sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
        sed -i "s/#$LOCALE/$LOCALE/" "${MNT_DIR}"/etc/locale.gen
    done
    for VARIABLE in "${LOCALE_CONF[@]}"; do
        #localectl set-locale "$VARIABLE"
        echo -e "$VARIABLE" >> "${MNT_DIR}"/etc/locale.conf
    done
    locale-gen
    arch-chroot "${MNT_DIR}" locale-gen
    echo -e "$KEYMAP\n$FONT\n$FONT_MAP" > "${MNT_DIR}"/etc/vconsole.conf
    echo "$HOSTNAME" > "${MNT_DIR}"/etc/hostname

    local OPTIONS=""
    if [ -n "$KEYLAYOUT" ]; then
        local OPTIONS="$OPTIONS"$'\n'"    Option \"XkbLayout\" \"$KEYLAYOUT\""
    fi
    if [ -n "$KEYMODEL" ]; then
        local OPTIONS="$OPTIONS"$'\n'"    Option \"XkbModel\" \"$KEYMODEL\""
    fi
    if [ -n "$KEYVARIANT" ]; then
        local OPTIONS="$OPTIONS"$'\n'"    Option \"XkbVariant\" \"$KEYVARIANT\""
    fi
    if [ -n "$KEYOPTIONS" ]; then
        local OPTIONS="$OPTIONS"$'\n'"    Option \"XkbOptions\" \"$KEYOPTIONS\""
    fi

    arch-chroot "${MNT_DIR}" mkdir -p "/etc/X11/xorg.conf.d/"
    cat <<EOT > "${MNT_DIR}/etc/X11/xorg.conf.d/00-keyboard.conf"
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
        echo "vm.swappiness=10" > "${MNT_DIR}"/etc/sysctl.d/99-sysctl.conf
    fi

    printf "%s\n%s" "$ROOT_PASSWORD" "$ROOT_PASSWORD" | arch-chroot "${MNT_DIR}" passwd
}

function mkinitcpio_configuration() {
    print_step "mkinitcpio_configuration()"

    if [ "$KMS" == "true" ]; then
        local MKINITCPIO_KMS_MODULES=""
        case "$DISPLAY_DRIVER" in
            "intel" )
                local MKINITCPIO_KMS_MODULES="i915"
                ;;
            "amdgpu" )
                local MKINITCPIO_KMS_MODULES="amdgpu"
                ;;
            "ati" )
                local MKINITCPIO_KMS_MODULES="radeon"
                ;;
            "nvidia" | "nvidia-lts"  | "nvidia-dkms" )
                local MKINITCPIO_KMS_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
                ;;
            "nouveau" )
                local MKINITCPIO_KMS_MODULES="nouveau"
                ;;
        esac
        local MODULES="$MODULES $MKINITCPIO_KMS_MODULES"
    fi
    if [ "$DISPLAY_DRIVER" == "intel" ]; then
        local OPTIONS=""
        if [ "$FASTBOOT" == "true" ]; then
            local OPTIONS="$OPTIONS fastboot=1"
        fi
        if [ "$FRAMEBUFFER_COMPRESSION" == "true" ]; then
            local OPTIONS="$OPTIONS enable_fbc=1"
        fi
        if [ -n "$OPTIONS" ]; then
            echo "options i915 $OPTIONS" > "${MNT_DIR}"/etc/modprobe.d/i915.conf
        fi
    fi

    if [ "$LVM" == "true" ]; then
        HOOKS=${HOOKS//!lvm2/lvm2}
    fi
    if [ "$BOOTLOADER" == "systemd" ]; then
        HOOKS=${HOOKS//!systemd/systemd}
        HOOKS=${HOOKS//!sd-vconsole/sd-vconsole}
        if [ -n "$LUKS_PASSWORD" ]; then
            HOOKS=${HOOKS//!sd-encrypt/sd-encrypt}
        fi
    else
        HOOKS=${HOOKS//!udev/udev}
        HOOKS=${HOOKS//!usr/usr}
        HOOKS=${HOOKS//!keymap/keymap}
        HOOKS=${HOOKS//!consolefont/consolefont}
        if [ -n "$LUKS_PASSWORD" ]; then
            HOOKS=${HOOKS//!encrypt/encrypt}
        fi
    fi

    HOOKS=$(sanitize_variable "$HOOKS")
    MODULES=$(sanitize_variable "$MODULES")
    arch-chroot "${MNT_DIR}" sed -i "s/^HOOKS=(.*)$/HOOKS=($HOOKS)/" /etc/mkinitcpio.conf
    arch-chroot "${MNT_DIR}" sed -i "s/^MODULES=(.*)/MODULES=($MODULES)/" /etc/mkinitcpio.conf

    if [ "$KERNELS_COMPRESSION" != "" ]; then
        arch-chroot "${MNT_DIR}" sed -i 's/^#COMPRESSION="'"$KERNELS_COMPRESSION"'"/COMPRESSION="'"$KERNELS_COMPRESSION"'"/' /etc/mkinitcpio.conf
    fi

    if [ "$KERNELS_COMPRESSION" == "bzip2" ]; then
        pacman_install "bzip2"
    fi
    if [ "$KERNELS_COMPRESSION" == "lzma" ] || [ "$KERNELS_COMPRESSION" == "xz" ]; then
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

function users() {
    print_step "users()"

    local USERS_GROUPS="wheel,storage,optical"
    create_user "$USER_NAME" "$USER_PASSWORD" "$USERS_GROUPS"

    for U in "${ADDITIONAL_USERS[@]}"; do
        local S=()
        IFS='=' read -ra S <<< "$U"
        local USER="${S[0]}"
        local PASSWORD="${S[1]}"
        create_user "$USER" "$PASSWORD" "$USERS_GROUPS"
    done

    arch-chroot "${MNT_DIR}" sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

    pacman_install "xdg-user-dirs"

    if [ "$SYSTEMD_HOMED" == "true" ]; then
        arch-chroot "${MNT_DIR}" systemctl enable systemd-homed.service

        cat <<EOT > "${MNT_DIR}/etc/pam.d/nss-auth"
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

        cat <<EOT > "${MNT_DIR}/etc/pam.d/system-auth"
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
    local USER=$1
    local PASSWORD=$2
    local USERS_GROUPS=$3
    if [ "$SYSTEMD_HOMED" == "true" ]; then
        create_user_homectl "$USER" "$PASSWORD" "$USERS_GROUPS"
    else
        create_user_useradd "$USER" "$PASSWORD" "$USERS_GROUPS"
    fi
}

function create_user_homectl() {
    local USER=$1
    local PASSWORD=$2
    local USER_GROUPS=$3
    local STORAGE="--storage=directory"
    local IMAGE_PATH="--image-path=${MNT_DIR}/home/$USER"
    local FS_TYPE=""
    local CIFS_DOMAIN=""
    local CIFS_USERNAME=""
    local CIFS_SERVICE=""
    local TZ=${TIMEZONE//\/usr\/share\/zoneinfo\//}
    local L=${LOCALE_CONF[0]//LANG=//}

    if [ "$SYSTEMD_HOMED_STORAGE" != "auto" ]; then
        local STORAGE="--storage=$SYSTEMD_HOMED_STORAGE"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "luks" ] && [ "$SYSTEMD_HOMED_STORAGE_LUKS_TYPE" != "auto" ]; then
        local FS_TYPE="--fs-type=$SYSTEMD_HOMED_STORAGE_LUKS_TYPE"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "luks" ]; then
        local IMAGE_PATH="--image-path=${MNT_DIR}/home/$USER.home"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "cifs" ]; then
        local CIFS_DOMAIN="--cifs-domain=${SYSTEMD_HOMED_CIFS_DOMAIN["domain"]}"
        local CIFS_USERNAME="--cifs-user-name=$USER"
        local CIFS_SERVICE="--cifs-service=${SYSTEMD_HOMED_CIFS_SERVICE["service"]}"
    fi
    if [ "$SYSTEMD_HOMED_STORAGE" == "luks" ] && [ "$SYSTEMD_HOMED_STORAGE_LUKS_TYPE" == "auto" ]; then
        pacman_install "btrfs-progs"
    fi

    systemctl start systemd-homed.service
    sleep 10 # #151 avoid Operation on home <USER> failed: Transport endpoint is not conected.
    homectl create "$USER" --enforce-password-policy=no --timezone="$TZ" --language="$L" "$STORAGE" "$IMAGE_PATH" "$FS_TYPE" "$CIFS_DOMAIN" "$CIFS_USERNAME" "$CIFS_SERVICE" -G "$USER_GROUPS"
    sleep 10 # #151 avoid Operation on home <USER> failed: Transport endpoint is not conected.
    cp -a "/var/lib/systemd/home/." "${MNT_DIR}/var/lib/systemd/home/"
}

function create_user_useradd() {
    local USER=$1
    local PASSWORD=$2
    local USER_GROUPS=$3
    arch-chroot "${MNT_DIR}" useradd -m -G "$USER_GROUPS" -s /bin/bash "$USER"
    printf "%s\n%s" "$USER_PASSWORD" "$USER_PASSWORD" | arch-chroot "${MNT_DIR}" passwd "$USER"
}

function user_add_groups() {
    local USER="$1"
    local USER_GROUPS="$2"
    if [ "$SYSTEMD_HOMED" == "true" ]; then
        homectl update "$USER" -G "$USER_GROUPS"
    else
        arch-chroot "${MNT_DIR}" usermod -a -G "$USER_GROUPS" "$USER"
    fi
}

function user_add_groups_lightdm() {
    arch-chroot "${MNT_DIR}" groupadd -r "autologin"
    user_add_groups "$USER_NAME" "autologin"

    for U in "${ADDITIONAL_USERS[@]}"; do
        local S=()
        IFS='=' read -ra S <<< "$U"
        local USER=${S[0]}
        user_add_groups "$USER" "autologin"
    done
}


function display_driver() {
    print_step "display_driver()"

    local PACKAGES_DRIVER_PACMAN="true"
    local PACKAGES_DRIVER=""
    local PACKAGES_DRIVER_MULTILIB=""
    local PACKAGES_DDX=""
    local PACKAGES_VULKAN=""
    local PACKAGES_VULKAN_MULTILIB=""
    local PACKAGES_HARDWARE_ACCELERATION=""
    local PACKAGES_HARDWARE_ACCELERATION_MULTILIB=""
    case "$DISPLAY_DRIVER" in
        "intel" )
            local PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "amdgpu" )
            local PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "ati" )
            local PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
        "nvidia" )
            local PACKAGES_DRIVER="nvidia"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-lts" )
            local PACKAGES_DRIVER="nvidia-lts"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-dkms" )
            local PACKAGES_DRIVER="nvidia-dkms"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-470xx-dkms" )
            local PACKAGES_DRIVER_PACMAN="false"
            local PACKAGES_DRIVER="nvidia-470xx-dkms"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-390xx-dkms" )
            local PACKAGES_DRIVER_PACMAN="false"
            local PACKAGES_DRIVER="nvidia-390xx-dkms"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nvidia-340xx-dkms" )
            local PACKAGES_DRIVER_PACMAN="false"
            local PACKAGES_DRIVER="nvidia-340xx-dkms"
            local PACKAGES_DRIVER_MULTILIB="lib32-nvidia-utils"
            ;;
        "nouveau" )
            local PACKAGES_DRIVER_MULTILIB="lib32-mesa"
            ;;
    esac
    if [ "$DISPLAY_DRIVER_DDX" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                local PACKAGES_DDX="xf86-video-intel"
                ;;
            "amdgpu" )
                local PACKAGES_DDX="xf86-video-amdgpu"
                ;;
            "ati" )
                local PACKAGES_DDX="xf86-video-ati"
                ;;
            "nouveau" )
                local PACKAGES_DDX="xf86-video-nouveau"
                ;;
        esac
    fi
    if [ "$VULKAN" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                local PACKAGES_VULKAN="vulkan-intel vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-vulkan-intel lib32-vulkan-icd-loader"
                ;;
            "amdgpu" )
                local PACKAGES_VULKAN="vulkan-radeon vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-vulkan-radeon lib32-vulkan-icd-loader"
                ;;
            "ati" )
                local PACKAGES_VULKAN="vulkan-radeon vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-vulkan-radeon lib32-vulkan-icd-loader"
                ;;
            "nvidia" )
                local PACKAGES_VULKAN="nvidia-utils vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils lib32-vulkan-icd-loader"
                ;;
            "nvidia-lts" )
                local PACKAGES_VULKAN="nvidia-utils vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils lib32-vulkan-icd-loader"
                ;;
            "nvidia-dkms" )
                local PACKAGES_VULKAN="nvidia-utils vulkan-icd-loader"
                local PACKAGES_VULKAN_MULTILIB="lib32-nvidia-utils lib32-vulkan-icd-loader"
                ;;
            "nouveau" )
                local PACKAGES_VULKAN=""
                local PACKAGES_VULKAN_MULTILIB=""
                ;;
        esac
    fi
    if [ "$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "intel" )
                if [ -n "$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL" ]; then
                    local PACKAGES_HARDWARE_ACCELERATION="$DISPLAY_DRIVER_HARDWARE_VIDEO_ACCELERATION_INTEL"
                    local PACKAGES_HARDWARE_ACCELERATION_MULTILIB=""
                fi
                ;;
            "amdgpu" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "ati" )
                local PACKAGES_HARDWARE_ACCELERATION="mesa-vdpau"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-mesa-vdpau"
                ;;
            "nvidia" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-lts" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-dkms" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-470xx-dkms" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-390xx-dkms" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nvidia-340xx-dkms" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
            "nouveau" )
                local PACKAGES_HARDWARE_ACCELERATION="libva-mesa-driver"
                local PACKAGES_HARDWARE_ACCELERATION_MULTILIB="lib32-libva-mesa-driver"
                ;;
        esac
    fi

    if [ "$PACKAGES_DRIVER_PACMAN" == "true" ]; then
        pacman_install "mesa $PACKAGES_DRIVER $PACKAGES_DDX $PACKAGES_VULKAN $PACKAGES_HARDWARE_ACCELERATION"
    else
        aur_install "mesa $PACKAGES_DRIVER $PACKAGES_DDX $PACKAGES_VULKAN $PACKAGES_HARDWARE_ACCELERATION"
    fi

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

    arch-chroot "${MNT_DIR}" mkinitcpio -P
}

function network() {
    print_step "network()"

    pacman_install "networkmanager"
    arch-chroot "${MNT_DIR}" systemctl enable NetworkManager.service
}

function virtualbox() {
    print_step "virtualbox()"

    pacman_install "virtualbox-guest-utils"
    arch-chroot "${MNT_DIR}" systemctl enable vboxservice.service

    local USER_GROUPS="vboxsf"
    user_add_groups "$USER_NAME" "$USER_GROUPS"

    for U in "${ADDITIONAL_USERS[@]}"; do
        local S=()
        IFS='=' read -ra S <<< "$U"
        local USER=${S[0]}
        user_add_groups "$USER" "$USER_GROUPS"
    done
}

function vmware() {
    print_step "vmware()"

    pacman_install "open-vm-tools"
    arch-chroot "${MNT_DIR}" systemctl enable vmtoolsd.service
}

function bootloader() {
    print_step "bootloader()"

    BOOTLOADER_ALLOW_DISCARDS=""

    if [ "$VIRTUALBOX" != "true" ] && [ "$VMWARE" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            pacman_install "intel-ucode"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            pacman_install "amd-ucode"
        fi
    fi
    if [ "$LVM" == "true" ] || [ -n "$LUKS_PASSWORD" ]; then
        CMDLINE_LINUX_ROOT="root=$DEVICE_ROOT"
    else
        CMDLINE_LINUX_ROOT="root=UUID=$UUID_ROOT"
    fi
    if [ -n "$LUKS_PASSWORD" ]; then
        case "$BOOTLOADER" in
            "grub" )
                if [ "$DEVICE_TRIM" == "true" ]; then
                    BOOTLOADER_ALLOW_DISCARDS=":allow-discards"
                fi
                CMDLINE_LINUX="cryptdevice=UUID=$UUID_ROOT:$LUKS_DEVICE_NAME$BOOTLOADER_ALLOW_DISCARDS"
                ;;
            "refind" )
                if [ "$DEVICE_TRIM" == "true" ]; then
                    BOOTLOADER_ALLOW_DISCARDS=":allow-discards"
                fi
                CMDLINE_LINUX="cryptdevice=UUID=$UUID_ROOT:$LUKS_DEVICE_NAME$BOOTLOADER_ALLOW_DISCARDS"
                ;;
            "systemd" )
                if [ "$DEVICE_TRIM" == "true" ]; then
                    BOOTLOADER_ALLOW_DISCARDS=" rd.luks.options=discard"
                fi
                CMDLINE_LINUX="rd.luks.name=$UUID_ROOT=$LUKS_DEVICE_NAME$BOOTLOADER_ALLOW_DISCARDS"
                ;;
        esac
    fi
    if [ "$FILE_SYSTEM_TYPE" == "btrfs" ]; then
        CMDLINE_LINUX="$CMDLINE_LINUX rootflags=subvol=${BTRFS_SUBVOLUME_ROOT[1]}"
    fi
    if [ "$KMS" == "true" ]; then
        case "$DISPLAY_DRIVER" in
            "nvidia" )
                CMDLINE_LINUX="$CMDLINE_LINUX nvidia-drm.modeset=1"
                ;;
        esac
    fi

    if [ -n "$KERNELS_PARAMETERS" ]; then
        CMDLINE_LINUX="$CMDLINE_LINUX $KERNELS_PARAMETERS"
    fi

    CMDLINE_LINUX=$(trim_variable "$CMDLINE_LINUX")

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

    arch-chroot "${MNT_DIR}" systemctl set-default multi-user.target
}

function bootloader_grub() {
    pacman_install "grub dosfstools"
    arch-chroot "${MNT_DIR}" sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
    arch-chroot "${MNT_DIR}" sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
    arch-chroot "${MNT_DIR}" sed -i -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
    arch-chroot "${MNT_DIR}" sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="'"$CMDLINE_LINUX"'"/' /etc/default/grub
    {
        echo ""
        echo "# alis"
        echo "GRUB_DISABLE_SUBMENU=y"
     }>> "${MNT_DIR}"/etc/default/grub

    if [ "$BIOS_TYPE" == "uefi" ]; then
        pacman_install "efibootmgr"
        arch-chroot "${MNT_DIR}" grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory="$ESP_DIRECTORY" --recheck
        #arch-chroot "${MNT_DIR}" efibootmgr --create --disk $DEVICE --part $PARTITION_BOOT_NUMBER --loader /EFI/grub/grubx64.efi --label "GRUB Boot Manager"
    fi
    if [ "$BIOS_TYPE" == "bios" ]; then
        arch-chroot "${MNT_DIR}" grub-install --target=i386-pc --recheck "$DEVICE"
    fi

    arch-chroot "${MNT_DIR}" grub-mkconfig -o "$BOOT_DIRECTORY/grub/grub.cfg"

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\grub\grubx64.efi" > "${MNT_DIR}$ESP_DIRECTORY/startup.nsh"
    fi
}

function bootloader_refind() {
    pacman_install "refind"
    arch-chroot "${MNT_DIR}" refind-install

    arch-chroot "${MNT_DIR}" rm /boot/refind_linux.conf
    arch-chroot "${MNT_DIR}" sed -i 's/^timeout.*/timeout 5/' "$ESP_DIRECTORY/EFI/refind/refind.conf"
    arch-chroot "${MNT_DIR}" sed -i 's/^#scan_all_linux_kernels.*/scan_all_linux_kernels false/' "$ESP_DIRECTORY/EFI/refind/refind.conf"
    #arch-chroot "${MNT_DIR}" sed -i 's/^#default_selection "+,bzImage,vmlinuz"/default_selection "+,bzImage,vmlinuz"/' "$ESP_DIRECTORY/EFI/refind/refind.conf"

    local REFIND_MICROCODE=""

    if [ "$VIRTUALBOX" != "true" ] && [ "$VMWARE" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            local REFIND_MICROCODE="initrd=/intel-ucode.img"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            local REFIND_MICROCODE="initrd=/amd-ucode.img"
        fi
    fi

    cat <<EOT >> "${MNT_DIR}${ESP_DIRECTORY}/EFI/refind/refind.conf"
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
        cat <<EOT >> "${MNT_DIR}${ESP_DIRECTORY}/EFI/refind/refind.conf"
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
        cat <<EOT >> "${MNT_DIR}${ESP_DIRECTORY}/EFI/refind/refind.conf"
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
        cat <<EOT >> "${MNT_DIR}${ESP_DIRECTORY}/EFI/refind/refind.conf"
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
        echo -ne "\EFI\refind\refind_x64.efi" > "${MNT_DIR}${ESP_DIRECTORY}/startup.nsh"
    fi
}

function bootloader_systemd() {
    arch-chroot "${MNT_DIR}" systemd-machine-id-setup
    arch-chroot "${MNT_DIR}" bootctl install

    arch-chroot "${MNT_DIR}" mkdir -p "$ESP_DIRECTORY/loader/"
    arch-chroot "${MNT_DIR}" mkdir -p "$ESP_DIRECTORY/loader/entries/"

    cat <<EOT > "${MNT_DIR}${ESP_DIRECTORY}/loader/loader.conf"
# alis
timeout 5
default archlinux.conf
editor 0
EOT

    #arch-chroot "${MNT_DIR}" systemctl enable systemd-boot-update.service

    arch-chroot "${MNT_DIR}" mkdir -p "/etc/pacman.d/hooks/"

    cat <<EOT > "${MNT_DIR}/etc/pacman.d/hooks/systemd-boot.hook"
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOT

    local SYSTEMD_MICROCODE=""

    if [ "$VIRTUALBOX" != "true" ] && [ "$VMWARE" != "true" ]; then
        if [ "$CPU_VENDOR" == "intel" ]; then
            local SYSTEMD_MICROCODE="/intel-ucode.img"
        fi
        if [ "$CPU_VENDOR" == "amd" ]; then
            local SYSTEMD_MICROCODE="/amd-ucode.img"
        fi
    fi

    echo "title Arch Linux" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux.conf"
    echo "efi /vmlinuz-linux" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux.conf"
    fi
    echo "initrd /initramfs-linux.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux.conf"
    echo "options initrd=initramfs-linux.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux.conf"

    echo "title Arch Linux (terminal)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-terminal.conf"
    echo "efi /vmlinuz-linux" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-terminal.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-terminal.conf"
    fi
    echo "initrd /initramfs-linux.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-terminal.conf"
    echo "options initrd=initramfs-linux.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-terminal.conf"

    echo "title Arch Linux (fallback)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-fallback.conf"
    echo "efi /vmlinuz-linux" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-fallback.conf"
    if [ -n "$SYSTEMD_MICROCODE" ]; then
        echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-fallback.conf"
    fi
    echo "initrd /initramfs-linux-fallback.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-fallback.conf"
    echo "options initrd=initramfs-linux-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-fallback.conf"

    if [[ $KERNELS =~ .*linux-lts.* ]]; then
        echo "title Arch Linux (lts)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts.conf"
        echo "efi /vmlinuz-linux-lts" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts.conf"
        fi
        echo "initrd /initramfs-linux-lts.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts.conf"
        echo "options initrd=initramfs-linux-lts.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts.conf"

        echo "title Arch Linux (lts, terminal)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-terminal.conf"
        echo "efi /vmlinuz-linux-lts" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-terminal.conf"
        fi
        echo "initrd /initramfs-linux-lts.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-terminal.conf"
        echo "options initrd=initramfs-linux-lts.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-terminal.conf"

        echo "title Arch Linux (lts-fallback)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-fallback.conf"
        echo "efi /vmlinuz-linux-lts" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-fallback.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-fallback.conf"
        fi
        echo "initrd /initramfs-linux-lts-fallback.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-fallback.conf"
        echo "options initrd=initramfs-linux-lts-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-lts-fallback.conf"
    fi

    if [[ $KERNELS =~ .*linux-hardened.* ]]; then
        echo "title Arch Linux (hardened)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened.conf"
        echo "efi /vmlinuz-linux-hardened" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened.conf"
        fi
        echo "initrd /initramfs-linux-hardened.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened.conf"
        echo "options initrd=initramfs-linux-hardened.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened.conf"

        echo "title Arch Linux (hardened, terminal)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-terminal.conf"
        echo "efi /vmlinuz-linux-hardened" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-terminal.conf"
        fi
        echo "initrd /initramfs-linux-hardened.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-terminal.conf"
        echo "options initrd=initramfs-linux-hardened.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-terminal.conf"

        echo "title Arch Linux (hardened-fallback)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-fallback.conf"
        echo "efi /vmlinuz-linux-hardened" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-fallback.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-fallback.conf"
        fi
        echo "initrd /initramfs-linux-hardened-fallback.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-fallback.conf"
        echo "options initrd=initramfs-linux-hardened-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-hardened-fallback.conf"
    fi

    if [[ $KERNELS =~ .*linux-zen.* ]]; then
        echo "title Arch Linux (zen)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen.conf"
        echo "efi /vmlinuz-linux-zen" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen.conf"
        fi
        echo "initrd /initramfs-linux-zen.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen.conf"
        echo "options initrd=initramfs-linux-zen.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen.conf"

        echo "title Arch Linux (zen, terminal)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-terminal.conf"
        echo "efi /vmlinuz-linux-zen" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-terminal.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-terminal.conf"
        fi
        echo "initrd /initramfs-linux-zen.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-terminal.conf"
        echo "options initrd=initramfs-linux-zen.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX systemd.unit=multi-user.target" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-terminal.conf"

        echo "title Arch Linux (zen-fallback)" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-fallback.conf"
        echo "efi /vmlinuz-linux-zen" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-fallback.conf"
        if [ -n "$SYSTEMD_MICROCODE" ]; then
            echo "initrd $SYSTEMD_MICROCODE" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-fallback.conf"
        fi
        echo "initrd /initramfs-linux-zen-fallback.img" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-fallback.conf"
        echo "options initrd=initramfs-linux-zen-fallback.img $CMDLINE_LINUX_ROOT rw $CMDLINE_LINUX" >> "${MNT_DIR}${ESP_DIRECTORY}/loader/entries/archlinux-zen-fallback.conf"
    fi

    if [ "$VIRTUALBOX" == "true" ]; then
        echo -n "\EFI\systemd\systemd-bootx64.efi" > "${MNT_DIR}${ESP_DIRECTORY}/startup.nsh"
    fi
}

function custom_shell() {
    print_step "custom_shell()"

    local CUSTOM_SHELL_PATH=""
    case "$CUSTOM_SHELL" in
        "zsh" )
            pacman_install "zsh"
            local CUSTOM_SHELL_PATH="/usr/bin/zsh"
            ;;
        "dash" )
            pacman_install "dash"
            local CUSTOM_SHELL_PATH="/usr/bin/dash"
            ;;
        "fish" )
            pacman_install "fish"
            local CUSTOM_SHELL_PATH="/usr/bin/fish"
            ;;
    esac

    if [ -n "$CUSTOM_SHELL_PATH" ]; then
        custom_shell_user "root" $CUSTOM_SHELL_PATH
        custom_shell_user "$USER_NAME" $CUSTOM_SHELL_PATH
        for U in "${ADDITIONAL_USERS[@]}"; do
            local S=()
            IFS='=' read -ra S <<< "$U"
            local USER=${S[0]}
            custom_shell_user "$USER" $CUSTOM_SHELL_PATH
        done
    fi
}


function custom_shell_user() {
    local USER="$1"
    local CUSTOM_SHELL_PATH="$2"

    if [ "$SYSTEMD_HOMED" == "true" ] && [ "$USER" != "root" ]; then
        homectl update --shell="$CUSTOM_SHELL_PATH" "$USER"
    else
        arch-chroot "${MNT_DIR}" chsh -s "$CUSTOM_SHELL_PATH" "$USER"
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
        "deepin" )
            desktop_environment_deepin
            ;;
        "budgie" )
            desktop_environment_budgie
            ;;
        "bspwm" )
            desktop_environment_bspwm
            ;;
        "awesome" )
            desktop_environment_awesome
            ;;
        "qtile" )
            desktop_environment_qtile
            ;;
        "openbox" )
            desktop_environment_openbox
            ;;
        "leftwm" )
            desktop_environment_leftwm
            ;;
        "dusk" )
            desktop_environment_dusk
            ;;
    esac

    arch-chroot "${MNT_DIR}" systemctl set-default graphical.target
}

function desktop_environment_gnome() {
    pacman_install "gnome"
}

function desktop_environment_kde() {
    pacman_install "plasma-meta plasma-wayland-session kde-system-meta kde-utilities-meta kde-graphics-meta kde-multimedia-meta kde-network-meta"
}

function desktop_environment_xfce() {
    pacman_install "xfce4 xfce4-goodies xorg-server pavucontrol pulseaudio"
}

function desktop_environment_mate() {
    pacman_install "mate mate-extra xorg-server"
}

function desktop_environment_cinnamon() {
    pacman_install "cinnamon gnome-terminal xorg-server"
}

function desktop_environment_lxde() {
    pacman_install "lxde"
}

function desktop_environment_i3_wm() {
    pacman_install "i3-wm i3blocks i3lock i3status dmenu rxvt-unicode xorg-server"
}

function desktop_environment_i3_gaps() {
    pacman_install "i3-gaps i3blocks i3lock i3status dmenu rxvt-unicode xorg-server"
}

function desktop_environment_deepin() {
    pacman_install "deepin deepin-extra deepin-kwin xorg xorg-server"
}

function desktop_environment_budgie() {
    pacman_install "budgie-desktop budgie-desktop-view budgie-screensaver gnome-control-center network-manager-applet gnome"
}

function desktop_environment_bspwm() {
    pacman_install "bspwm"
}

function desktop_environment_awesome() {
    pacman_install "awesome vicious xterm xorg-server"
}

function desktop_environment_qtile() {
    pacman_install "qtile xterm xorg-server"
}

function desktop_environment_openbox() {
    pacman_install "openbox obconf xterm xorg-server"
}

function desktop_environment_leftwm() {
    aur_install "leftwm-git leftwm-theme-git dmenu xterm xorg-server"
}

function desktop_environment_dusk() {
    aur_install "dusk-git dmenu xterm xorg-server"
}

function display_manager() {
    print_step "display_manager()"

    if [ "$DISPLAY_MANAGER" == "auto" ]; then
        case "$DESKTOP_ENVIRONMENT" in
            "gnome" )
                display_manager_gdm
                ;;
            "kde" )
                display_manager_sddm
                ;;
            "xfce" )
                display_manager_lightdm
                ;;
            "mate" )
                display_manager_lightdm
                ;;
            "cinnamon" )
                display_manager_lightdm
                ;;
            "lxde" )
                display_manager_lxdm
                ;;
            "i3-wm" )
                display_manager_lightdm
                ;;
            "i3-gaps" )
                display_manager_lightdm
                ;;
            "deepin" )
                display_manager_lightdm
                ;;
            "budgie" )
                display_manager_gdm
                ;;
            "bspwm" )
                display_manager_lightdm
                ;;
            "awesome" )
                display_manager_lightdm
                ;;
            "qtile" )
                display_manager_lightdm
                ;;
            "openbox" )
                display_manager_lightdm
                ;;
            "leftwm" )
                display_manager_lightdm
                ;;
            "dusk" )
                display_manager_lightdm
                ;;
        esac
    else
        case "$DISPLAY_MANAGER" in
            "gdm" )
                display_manager_gdm
                ;;
            "sddm" )
                display_manager_sddm
                ;;
            "lightdm" )
                display_manager_lightdm
                ;;
            "lxdm" )
                display_manager_lxdm
                ;;
        esac
    fi
}

function display_manager_gdm() {
    pacman_install "gdm"
    arch-chroot "${MNT_DIR}" systemctl enable gdm.service
}

function display_manager_sddm() {
    pacman_install "sddm"
    arch-chroot "${MNT_DIR}" systemctl enable sddm.service
}

function display_manager_lightdm() {
    pacman_install "lightdm lightdm-gtk-greeter"
    arch-chroot "${MNT_DIR}" systemctl enable lightdm.service
    user_add_groups_lightdm

    if [ "$DESKTOP_ENVIRONMENT" == "deepin" ]; then
        arch-chroot "${MNT_DIR}" sed -i 's/^#greeter-session=.*/greeter-session=lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
        arch-chroot "${MNT_DIR}" systemctl enable lightdm.service
    fi
}

function display_manager_lxdm() {
    pacman_install "lxdm"
    arch-chroot "${MNT_DIR}" systemctl enable lxdm.service
}

function packages() {
    print_step "packages()"

    if [ "$PACKAGES_INSTALL" == "true" ]; then
        USER_NAME="$USER_NAME" \
        USER_PASSWORD="$USER_PASSWORD" \
        PACKAGES_PIPEWIRE="$PACKAGES_PIPEWIRE" \
        COMMOMS_LOADED="$COMMOMS_LOADED" \
        MNT_DIR="${MNT_DIR}" \
            ./alis-packages.sh
        if [ "$?" != "0" ]; then
            exit 1
        fi
    fi
}

function provision() {
    print_step "provision()"

    (cd "$PROVISION_DIRECTORY" && cp -vr --parents . "${MNT_DIR}")
}

function vagrant() {
    pacman_install "openssh"
    create_user "vagrant" "vagrant"
    arch-chroot "${MNT_DIR}" systemctl enable sshd.service
    arch-chroot "${MNT_DIR}" ssh-keygen -A
    arch-chroot "${MNT_DIR}" sshd -t
}

function end() {
    echo ""
    echo -e "${GREEN}Arch Linux installed successfully"'!'"${NC}"
    echo ""

    if [ "$REBOOT" == "true" ]; then
        REBOOT="true"

        set +e
        for (( i = 15; i >= 1; i-- )); do
            read -r -s -n 1 -t 1 -p "Rebooting in $i seconds... Press Esc key to abort or press R key to reboot now."$'\n' KEY
            local CODE="$?"
            if [ "$CODE" != "0" ]; then
                continue
            fi
            if [ "$KEY" == $'\e' ]; then
                REBOOT="false"
                break
            elif [ "$KEY" == "r" ] || [ "$KEY" == "R" ]; then
                REBOOT="true"
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

            copy_logs
        fi
    else
        if [ "$ASCIINEMA" == "true" ]; then
            echo "No reboot. You will must terminate asciinema recording and do a explicit reboot (exit, ./alis-reboot.sh)."
            echo ""
        else
            echo "No reboot. You will must do a explicit reboot (./alis-reboot.sh)."
            echo ""
        fi

        copy_logs
    fi
}

function copy_logs() {
    local ESCAPED_LUKS_PASSWORD=${LUKS_PASSWORD//[.[\*^$()+?{|]/[\\&]}
    local ESCAPED_ROOT_PASSWORD=${ROOT_PASSWORD//[.[\*^$()+?{|]/[\\&]}
    local ESCAPED_USER_PASSWORD=${USER_PASSWORD//[.[\*^$()+?{|]/[\\&]}

    if [ -f "$ALIS_CONF_FILE" ]; then
        local SOURCE_FILE="$ALIS_CONF_FILE"
        local FILE="${MNT_DIR}/var/log/alis/$ALIS_CONF_FILE"

        mkdir -p "${MNT_DIR}"/var/log/alis
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
    if [ -f "$ALIS_LOG_FILE" ]; then
        local SOURCE_FILE="$ALIS_LOG_FILE"
        local FILE="${MNT_DIR}/var/log/alis/$ALIS_LOG_FILE"

        mkdir -p "${MNT_DIR}"/var/log/alis
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
    if [ -f "$ALIS_ASCIINEMA_FILE" ]; then
        local SOURCE_FILE="$ALIS_ASCIINEMA_FILE"
        local FILE="${MNT_DIR}/var/log/alis/$ALIS_ASCIINEMA_FILE"

        mkdir -p "${MNT_DIR}"/var/log/alis
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

function main() {
    local START_TIMESTAMP=$(date -u +"%F %T")
    init_config

    while getopts "w" arg; do
        case $arg in
            w)
                WARNING_CONFIRM="false"
                ;;
            *) ;;
        esac
    done

    execute_step "sanitize_variables"
    execute_step "check_variables"
    execute_step "warning"
    execute_step "init"
    execute_step "facts"
    execute_step "checks"
    execute_step "prepare"
    execute_step "partition"
    execute_step "install"
    execute_step "configuration"
    execute_step "mkinitcpio_configuration"
    execute_step "users"
    if [ -n "$DISPLAY_DRIVER" ]; then
        execute_step "display_driver"
    fi
    execute_step "kernels"
    execute_step "mkinitcpio"
    execute_step "network"
    if [ "$VIRTUALBOX" == "true" ]; then
        execute_step "virtualbox"
    fi
    if [ "$VMWARE" == "true" ]; then
        execute_step "vmware"
    fi
    execute_step "bootloader"
    if [ -n "$CUSTOM_SHELL" ]; then
        execute_step "custom_shell"
    fi
    if [ -n "$DESKTOP_ENVIRONMENT" ]; then
        execute_step "desktop_environment"
        execute_step "display_manager"
    fi
    execute_step "packages"
    if [ "$PROVISION" == "true" ]; then
        execute_step "provision"
    fi
    if [ "$VAGRANT" == "true" ]; then
        execute_step "vagrant"
    fi
    execute_step "systemd_units"
    local END_TIMESTAMP=$(date -u +"%F %T")
    local INSTALLATION_TIME=$(date -u -d @$(($(date -d "$END_TIMESTAMP" '+%s') - $(date -d "$START_TIMESTAMP" '+%s'))) '+%T')
    echo -e "Installation start ${WHITE}$START_TIMESTAMP${NC}, end ${WHITE}$END_TIMESTAMP${NC}, time ${WHITE}$INSTALLATION_TIME${NC}"
    execute_step "end"
}

main "$@"
