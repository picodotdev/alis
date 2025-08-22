
    #####################################################################
    # 
    # How to use this repo for default hyprland & ml4w dotfiles install
    #
    #####################################################################

    #####################################################################
    # alis.conf
    #####################################################################
        Set:-
            TIMEZONE
            LOCALES
            LOCALE_CONF
            KEYLAYOUT
            HOSTNAME

            USER_NAME

        If using wifi on bare metal, Set:- 

            WIFI_INTERFACE
            WIFI_ESSID
            WIFI_KEY
            WIFI_KEY_RETYPE
            PING_HOSTNAME

    #####################################################################
    # alis-packages.conf
    #####################################################################

        Add desired packages to each section following naming conventions
            i.e for normal repo package "git"
                for flatpak "org.mozilla.firefox"
        ! before package skips during install

    #####################################################################
    # alis-commons.conf
    #####################################################################
        Set:-
            USER_NAME

    #####################################################################
    # download.sh
    #####################################################################
        Set:-
            GITHUB_USER

    #####################################################################
    # Install
    #####################################################################

    Run Arch iso

    In tty use:-
        loadskeys uk
        curl -LO https://raw.githubusercontent.com/libertine89/alis/main/download.sh && bash download.sh && bash alis.sh

    Confirm install with Y and then set & confirm root password & user password

    When arch install is complete, confirm reboot or wait

    After reboot enter user password and login
    Open terminal with Meta+Q & run command:-
        curl -LO https://raw.githubusercontent.com/libertine89/alis/main/post-install.sh && bash post-install.sh
    Confirm package installatiosn with Y & enter user password when prompted
    When completed wait for reboot & login