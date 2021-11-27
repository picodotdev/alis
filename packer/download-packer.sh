#!/usr/bin/env bash
set -e

curl -O http://$1:$2/alis.conf
curl -O http://$1:$2/alis.sh
curl -O http://$1:$2/alis-packages.conf
curl -O http://$1:$2/alis-packages.sh
curl -O http://$1:$2/alis-reboot.sh
curl -O http://$1:$2/alis-asciinema.sh
curl -o ./alis-packer-conf.sh -O http://$1:$2/packer/$3
chmod +x ./*.sh

