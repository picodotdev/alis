#!/usr/bin/env bash
set -eu

GITHUB_USER="picodotdev"
BRANCH="master"
BRANCH_QUALIFIER=""
IP_ADDRESS=""
VM_TYPE="virtualbox"
VM_NAME="Arch Linux"
CONFIG_FILE_SH=""

while getopts "b:c:i:n:t:u:" arg; do
  case $arg in
    b)
      BRANCH="$OPTARG"
      ;;
    c)
      CONFIG_FILE_SH="$OPTARG"
      ;;
    i)
      IP_ADDRESS="$OPTARG"
      ;;
    n)
      VM_NAME="$OPTARG"
      ;;
    t)
      VM_TYPE="$OPTARG"
      ;;
    u)
      GITHUB_USER=${OPTARG}
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

if [ "$BRANCH" == "sid" ]; then
  BRANCH_QUALIFIER="-sid"
fi

if [ "$IP_ADDRESS" == "" ] && [ "$VM_TYPE" != "" ] && [ "$VM_NAME" != "" ]; then
  IP_ADDRESS=$(VBoxManage guestproperty get "${VM_NAME}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | cut -f2 -d " ")
fi

set -o xtrace
ssh-keygen -R "$IP_ADDRESS"
ssh-keyscan -H "$IP_ADDRESS" >> ~/.ssh/known_hosts

ssh -t -i cloud-init/alis.key root@"$IP_ADDRESS" "bash -c \"curl -sL https://raw.githubusercontent.com/${GITHUB_USER}/alis/${BRANCH}/download${BRANCH_QUALIFIER}.sh | bash -s -- -b ${BRANCH}\""

if [ -z "$CONFIG_FILE_SH" ]; then
  ssh -t -i cloud-init/alis.key root@"$IP_ADDRESS"
else
  ssh -t -i cloud-init/alis.key root@"$IP_ADDRESS" "bash -c \"configs/$CONFIG_FILE_SH\""
  ssh -t -i cloud-init/alis.key root@"$IP_ADDRESS" "bash -c \"./alis.sh -w\""
fi
