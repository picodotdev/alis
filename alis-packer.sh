#!/usr/bin/env bash
set -e

packer validate alis-packer.json
packer build -force alis-packer.json