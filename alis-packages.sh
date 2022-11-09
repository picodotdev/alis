#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155,SC2034
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC2155 Declare and assign separately to avoid masking return values
# SC2034: foo appears unused. Verify it or export it.
set -eu

# Arch Linux Install Script Packages (alis-packages) installs software
# packages.
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

# Installs packages in a Arch Linux system.
#
# Usage:
# # loadkeys es
# # curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
# # vim alis-packages.conf
# # ./alis-packages.sh

PACKAGES_STANDALONE="false"

function init_config() {
    local COMMONS_FILE="alis-commons.sh"

    source "$COMMONS_FILE"
    if [ "$PACKAGES_STANDALONE" == "true" ]; then
        source "$COMMONS_CONF_FILE"
    fi
    source "$PACKAGES_CONF_FILE"
}

function sanitize_variables() {
    PACKAGES_PACMAN=$(sanitize_variable "$PACKAGES_PACMAN")
    PACKAGES_PACMAN_PIPEWIRE=$(sanitize_variable "$PACKAGES_PACMAN_PIPEWIRE")
    PACKAGES_FLATPAK=$(sanitize_variable "$PACKAGES_FLATPAK")
    PACKAGES_SDKMAN=$(sanitize_variable "$PACKAGES_SDKMAN")
    PACKAGES_AUR_COMMAND=$(sanitize_variable "$PACKAGES_AUR_COMMAND")
    PACKAGES_AUR=$(sanitize_variable "$PACKAGES_AUR")
    SYSTEMD_UNITS=$(sanitize_variable "$SYSTEMD_UNITS")
}

function check_variables() {
    check_variables_boolean "PACKAGES_PACMAN_INSTALL" "$PACKAGES_PACMAN_INSTALL"
    check_variables_boolean "PACKAGES_PACMAN_INSTALL_PIPEWIRE" "$PACKAGES_PACMAN_INSTALL_PIPEWIRE"
    check_variables_boolean "PACKAGES_FLATPAK_INSTALL" "$PACKAGES_FLATPAK_INSTALL"
    check_variables_boolean "PACKAGES_SDKMAN_INSTALL" "$PACKAGES_SDKMAN_INSTALL"
    check_variables_boolean "PACKAGES_AUR_INSTALL" "$PACKAGES_AUR_INSTALL"
    check_variables_list "PACKAGES_AUR_COMMAND" "$PACKAGES_AUR_COMMAND" "paru-bin yay-bin paru yay aurman" "true" "false"
}

function init() {
    if [ "$PACKAGES_STANDALONE" == "true" ]; then
        init_log_trace "$LOG_TRACE"
        init_log_file "$LOG_FILE" "$PACKAGES_LOG_FILE"
    fi
}

function facts() {
    print_step "facts()"

    facts_commons

    if [ -z "$USER_NAME" ]; then
        USER_NAME="$(whoami)"
    fi
}

function checks() {
    print_step "checks()"

    check_variables_value "USER_NAME" "$USER_NAME"

    if [ -n "$PACKAGES_PACMAN" ]; then
        execute_sudo "pacman -Syi $PACKAGES_PACMAN"
    fi

    if [ "$SYSTEM_INSTALLATION" == "false" ]; then
        ask_sudo
    fi
}

function ask_sudo() {
    sudo pwd >> /dev/null
}

function prepare() {
    print_step "prepare()"
}

function packages() {
    print_step "packages()"

    packages_pacman
    packages_flatpak
    packages_sdkman
    packages_aur
}

function packages_pacman() {
    print_step "packages_pacman()"

    if [ "$PACKAGES_PACMAN_INSTALL" == "true" ]; then
        local CUSTOM_REPOSITORIES="$(echo "$PACKAGES_PACMAN_CUSTOM_REPOSITORIES" | grep -E "^[^#]|\n^$"; exit 0)"
        if [ -n "$CUSTOM_REPOSITORIES" ]; then
            execute_sudo "echo -e \"# alis\n$CUSTOM_REPOSITORIES\" >> /etc/pacman.conf"
        fi

        if [ -n "$PACKAGES_PACMAN" ]; then
            pacman_install "$PACKAGES_PACMAN"
        fi

        if [[ ("$PACKAGES_PIPEWIRE" == "true" || "$PACKAGES_PACMAN_INSTALL_PIPEWIRE" == "true") && -n "$PACKAGES_PACMAN_PIPEWIRE" ]]; then
            if echo "$PACKAGES_PACMAN_PIPEWIRE" | grep -F -qw "pipewire-pulse"; then
                pacman_uninstall "pulseaudio pulseaudio-bluetooth"
            fi
            if echo "$PACKAGES_PACMAN_PIPEWIRE" | grep -F -qw "pipewire-alsa"; then
                pacman_uninstall "pulseaudio pulseaudio-alsa"
            fi
            if echo "$PACKAGES_PACMAN_PIPEWIRE" | grep -F -qw "wireplumber"; then
                pacman_uninstall "pipewire-media-session"
            fi
            if echo "$PACKAGES_PACMAN_PIPEWIRE" | grep -F -qw "pipewire-jack"; then
                pacman_uninstall "jack2"
            fi
            pacman_install "$PACKAGES_PACMAN_PIPEWIRE"
            #if [ -n "$(echo "$PACKAGES_PACMAN_PIPEWIRE" | grep -F -w "pipewire-pulse")" ]; then
            #    execute_user "$USER_NAME" "systemctl enable --user pipewire-pulse.service"
            #fi
        fi
    fi
}

function packages_flatpak() {
    print_step "packages_flatpak()"

    if [ "$PACKAGES_FLATPAK_INSTALL" == "true" ]; then
        pacman_install "flatpak"

        if [ -n "$PACKAGES_FLATPAK" ]; then
            execute_flatpak "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"

            flatpak_install "$PACKAGES_FLATPAK"
        fi
    fi
}

function packages_sdkman() {
    print_step "packages_sdkman()"

    if [ "$PACKAGES_SDKMAN_INSTALL" == "true" ]; then
        pacman_install "zip unzip"
        execute_user "$USER_NAME" "curl -s https://get.sdkman.io | bash"

        if [ -n "$PACKAGES_SDKMAN" ]; then
            execute_user "$USER_NAME" "sed -i 's/sdkman_auto_answer=.*/sdkman_auto_answer=true/g' /home/$USER_NAME/.sdkman/etc/config"
            sdkman_install "$PACKAGES_SDKMAN"
            execute_user "$USER_NAME" "sed -i 's/sdkman_auto_answer=.*/sdkman_auto_answer=false/g' /home/$USER_NAME/.sdkman/etc/config"
        fi
    fi
}

function packages_aur() {
    print_step "packages_aur()"

    if [ "$PACKAGES_AUR_INSTALL" == "true" ]; then
        local COMMANDS=()
        IFS=' ' read -ra COMMANDS <<< "$PACKAGES_AUR_COMMAND"
        for COMMAND in "${COMMANDS[@]}"
        do
            aur_command_install "$USER_NAME" "$COMMAND"
        done

        AUR_PACKAGE="${COMMANDS[0]}"

        case "${AUR_PACKAGE}" in
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

        if [ -n "$PACKAGES_AUR" ]; then
            aur_install "$PACKAGES_AUR"
        fi
    fi
}

function flatpak_install() {
    local OPTIONS=""
    if [ "$SYSTEM_INSTALLATION" == "true" ]; then
        local OPTIONS="--system"
    fi

    local ERROR="true"
    local PACKAGES=()
    set +e
    IFS=' ' read -ra PACKAGES <<< "$1"
    for VARIABLE in {1..5}
    do
        local COMMAND="flatpak install $OPTIONS -y flathub ${PACKAGES[*]}"
        if ! execute_flatpak "$COMMAND"; then
            local ERROR="false"
            break
        else
            sleep 10
        fi
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function sdkman_install() {
    local ERROR="true"
    local PACKAGES=()
    local PACKAGE=""
    local I=()
    set +e
    IFS=' ' read -ra PACKAGES <<< "$1"
    for PACKAGE in "${PACKAGES[@]}"
    do
        IFS=':' read -ra I <<< "$PACKAGE"
        for VARIABLE in {1..5}
        do
            local COMMAND="source /home/$USER_NAME/.sdkman/bin/sdkman-init.sh && sdk install ${I[*]}"
            if ! execute_user "$USER_NAME" "$COMMAND"; then
                local ERROR="false"
                break
            else
                sleep 10
            fi
        done
    done
    set -e
    if [ "$ERROR" == "true" ]; then
        return
    fi
}

function end() {
    echo ""
    echo -e "${GREEN}Arch Linux packages installed successfully"'!'"${NC}"
    echo ""
}

function main() {
    local START_TIMESTAMP=$(date -u +"%F %T")
    set +u
    if [ "$COMMOMS_LOADED" != "true" ]; then
        PACKAGES_STANDALONE="true"
    fi
    set -u

    init_config
    execute_step "sanitize_variables"
    execute_step "check_variables"
    execute_step "init"
    execute_step "facts"
    execute_step "checks"
    execute_step "prepare"
    execute_step "packages"
    execute_step "systemd_units"
    local END_TIMESTAMP=$(date -u +"%F %T")
    local INSTALLATION_TIME=$(date -u -d @$(($(date -d "$END_TIMESTAMP" '+%s') - $(date -d "$START_TIMESTAMP" '+%s'))) '+%T')
    echo -e "Installation packages start ${WHITE}$START_TIMESTAMP${NC}, end ${WHITE}$END_TIMESTAMP${NC}, time ${WHITE}$INSTALLATION_TIME${NC}"
    execute_step "end"
}

main 

"$@"