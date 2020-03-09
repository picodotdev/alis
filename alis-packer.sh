#!/usr/bin/env bash
set -e

CONFIG_FILE="alis-packer-efi-ext4-luks-lvm-grub.json"

while getopts "c:" arg; do
  case $arg in
    c)
      CONFIG_FILE=$OPTARG
      ;;
  esac
done

packer validate "packer/$CONFIG_FILE"
packer build -force "packer/$CONFIG_FILE"