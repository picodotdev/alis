#!/usr/bin/env bash
set -eu

# https://wiki.archlinux.org/title/Libvirt#Server
# https://wiki.archlinux.org/title/QEMU#Bridged_networking_using_qemu-bridge-helper
# sudo pacman -S virt-install dnsmasq dmidecode
# sudo usermod -a -G libvirtd picodotdev
# sudo systemctl start libvirtd.service
# mkdir -p /etc/qemu
# vim /etc/qemu/bridge.conf
# allow virbr0

# 3D Acceleration
# Host and guest shared clipboard
# Host and guest file sharing

DISK_DIRECTORY="/run/media/picodotdev/Samsung microSD/KVM VMs"
ISO_DIRECTORY="/run/media/picodotdev/Samsung microSD/Iso"

virt-install \
    --connect=qemu:///session \
    --name archlinux-alis \
    --os-variant archlinux \
    --vcpu 2 \
    --ram 4096 \
    --boot uefi \
    --disk path="$DISK_DIRECTORY/archlinux-alis.qcow2,format=qcow2,size=40,sparse=yes" \
    --cdrom "$ISO_DIRECTORY/archlinux-2022.11.01-x86_64.iso" \
    --disk cloud-init/alis-cloud-init.iso,device=cdrom,bus=sata \
    --network bridge=virbr0 \
    --noautoconsole
