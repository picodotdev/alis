# alis

Arch Linux Install Script (alis) installs unattended, automated and customized Arch Linux system.

For new features, improvements and bugs fill an issue in GitHub or make a pull request.

Please, don't ask for support for this script in Arch Linux forums, first read
the [Arch Linux wiki](https://wiki.archlinux.org), the [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) and the [General
Recomendations](https://wiki.archlinux.org/index.php/General_recommendations), later
compare the commands with those of this script.

You can test it in a VirtualBox virtual machine.

### Features

* BIOS with GPT
* UEFI
* LVM and no LVM
* _root_ partition encrypted and no encrypted
* LVM on LUKS when LVM and encrypted
* File system formats ext4, btrfs (no swap), xfs
* File swap
* WPA WIFI network installation
* TRIM for SSD storage
* VirtualBox guest utils
* Intel processors microcode
* Users creation and add to sudoers
* yaourt installation
* Custom packages installation
* Desktop environments (GDM, KDE, XFCE, Mate, Cinnamon, LXDE), display managers (GDM, SDDM, Lightdm, lxdm) and no desktop environments
* Additional kernels installation (linux-lts, linux-hardened, linux-zen)
* Kernels compression
* Graphics controllers (intel, nvidia, amd) with early KMS start
* GRUB bootloader

### Usage

* \# Start the system with lastest Arch Linux installation media
* $ loadkeys [keymap]
* $ wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.conf
* $ nano alis.conf
* \# Edit alis.conf and change variables values with your preferences
* $ wget https://raw.githubusercontent.com/picodotdev/alis/master/alis.sh
* $ chmod +x alis.sh
* $ ./alis.sh

### TODO

* systemd-boot?
* /boot/efi/EFI?
* GNOME, fuente de entrada (teclado), https://unix.stackexchange.com/questions/316998/how-to-change-keyboard-layout-in-gnome-3-from-command-line, https://askubuntu.com/questions/276509/change-gsettings-without-running-x-and-unity
> gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'es')]"
* GNOME, KDE autologin
> ??? gsettings set org.gnome.desktop.lockdown disable-lock-screen true
* Common packages SSH, bluethooth, ntfs-3g, dosfstools, ...
* Not delete everything, specific partitions
* GRUB theme
* Icon theme (numix), antergos GNOME theme
* rEFInd
* Custom shell interpreter
* Retry failed package download error
* Ncurses with Vala (ValaNcurses.vala, commands output to file, copy file to installed system?)
* Review https://linuxgnublog.org/es/instalacion-de-arch-linux/, https://github.com/erm2587/ArchLinuxInstaller
