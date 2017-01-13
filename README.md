# alis

Arch Linux Install Script (alis) installs unnatended, automated and customized Arch Linux system.

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
* File system formats ext4, btrfs (no swap), xfs
* File swap
* WPA WIFI network installation
* TRIM for SSD storage
* VirtualBox guest utils
* Intel processors microcode
* User creation
* yaourt installation
* Custom packages installation
* Desktop environments (GDM, KDE, XFCE, Mate, Cinnamon, LXDE), display managers (GDM, SDDM, Lightdm, lxdm) and no desktop environments
* Additional kernels installation (linux-lts, linux-grsec, linux-zen)
* Graphics controllers (intel, nvidia, amd)
* GRUB bootloader

### Usage

* Start the system with lastest Arch Linux installation media
* wget -O alis.conf https://raw.githubusercontent.com/picodotdev/alis/master/alis.conf
* nano alis.conf
* # Edit variables values with your preferences
* wget -O alis.sh https://raw.githubusercontent.com/picodotdev/alis/master/alis.sh
* chmod +x alis.sh
* ./alis.sh
