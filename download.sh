#!/usr/bin/env bash
set -e

# Arch Linux Install Script Download (alis-download) downloads scripts.
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
# # curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
# # # see alis.sh or alis-recovery.sh usage

rm -f alis.conf
rm -f alis.sh
rm -f alis-recovery.conf
rm -f alis-recovery.sh
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.conf
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.sh
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis-recovery.conf
wget https://raw.githubusercontent.com/picodotdev/alis/master/alis-recovery.sh
chmod +x alis.sh
chmod +x alis-recovery.sh