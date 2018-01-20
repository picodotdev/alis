# alis

Arch Linux Install Script (alis) installs unattended, automated and customized Arch Linux system.

For new features, improvements and bugs fill an issue in GitHub or make a pull request.

Please, don't ask for support for this script in Arch Linux forums, first read
the [Arch Linux wiki](https://wiki.archlinux.org), the [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) and the [General
Recomendations](https://wiki.archlinux.org/index.php/General_recommendations), later
compare the those commands with the commands of this script.

For new features, improvements and bugs fill an issue in GitHub or make a pull request. You can test it in a VirtualBox virtual machine. If you test it in real hardware please send me an email to pico.dev@gmail.com with the machine description and tell me if something goes wrong or all works fine. [Pull request](https://github.com/picodotdev/alis/pulls) and [new feature request](https://github.com/picodotdev/alis/issues) are welcome!

### Features

* GPT
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
* GRUB, rEFInd, systemd-boot bootloaders
* Script for download installation and recovery scripts and configuration files
* Wait after installation for a abortable reboot

### Installation

```
# # Start the system with lastest Arch Linux installation media
# loadkeys [keymap]
# curl -s "https://raw.githubusercontent.com/picodotdev/alis/master/download.sh" | bash
# # Edit alis.conf and change variables values with your preferences
# vim alis.conf
# ./alis.sh
```

### Recovery

```
# # Start the system with lastest Arch Linux installation media
# loadkeys [keymap]
# curl -s "https://raw.githubusercontent.com/picodotdev/alis/master/download.sh" | bash
# # Edit alis.conf and change variables values with your preferences
# vim alis-recovery.conf
# ./alis-recovery.sh
```
