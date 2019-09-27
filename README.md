# alis

Arch Linux Install Script (alis) installs unattended, automated and customized Arch Linux system.

This a simple bash script for an easy and fast way of installing Arch Linux, follow the [Arch Way](https://wiki.archlinux.org/index.php/Arch_Linux) of doing things and learn what this script does. This will allow you to know what is happening. 

Please, don't ask for support for this script in Arch Linux forums, first read
the [Arch Linux wiki](https://wiki.archlinux.org), the [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) and the [General
Recomendations](https://wiki.archlinux.org/index.php/General_recommendations), later
compare those commands with the commands of this script.

For new features, improvements and bugs fill an issue in GitHub or make a pull request. You can test it in a VirtualBox virtual machine (recommended) before run it in real hardware. If you test it in real hardware please send me an email to pico.dev@gmail.com with the machine description and tell me if something goes wrong or all works fine. [Pull request](https://github.com/picodotdev/alis/pulls) and [new feature request](https://github.com/picodotdev/alis/issues) are welcome!

**Warning! This script deletes all partitions of the persistent storage**

Currently these scripts are for me but maybe they are useful for you too.

### Features

* GPT, UEFI, BIOS
* Support for SATA, NVMe and MMC
* LVM and no LVM
* _root_ partition encrypted and no encrypted
* LVM on LUKS when LVM and encrypted
* File system formats ext4, btrfs (no swap), xfs
* Optional file swap
* WPA WIFI network installation
* Periodic TRIM for SSD storage
* VirtualBox guest utils
* Intel processors microcode
* Users creation and add to sudoers
* Common and custom packages installation
* AUR utility installation (aurman, yay)
* Retry packages download on connection/mirror error
* Desktop environments (GDM, KDE, XFCE, Mate, Cinnamon, LXDE), display managers (GDM, SDDM, Lightdm, lxdm) and no desktop environment
* Additional kernel installation (linux-lts, linux-hardened, linux-zen)
* Kernel compression
* Graphic controllers (intel, nvidia, amd) with optionally early KMS start
* GRUB, rEFInd, systemd-boot bootloaders
* Script for download installation and recovery scripts and configuration files
* Installation log with all commands executed and output in a file and/or asciinema video
* Wait after installation for an abortable reboot

### Installation

Internet connection is required, with wireless WIFI connection see [Wireless_network_configuration](https://wiki.archlinux.org/index.php/Wireless_network_configuration#Wi-Fi_Protected_Access) to bring up WIFI connection before starting installation with alis.

```
# # Start the system with lastest Arch Linux installation media
# loadkeys [keymap]
# curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# # Edit alis.conf and change variables values with your preferences
# vim alis.conf
# ./alis.sh
```

### Installation with asciinema vídeo

As another form of log.

```
# # Start the system with lastest Arch Linux installation media
# loadkeys [keymap]
# curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# ./alis-asciinema.sh
# # Edit alis.conf and change variables values with your preferences
# vim alis.conf
# ./alis.sh
# exit
# ./alis-reboot.sh
```

### Recovery

```
# # Start the system with lastest Arch Linux installation media
# loadkeys [keymap]
# curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash, or with URL shortener curl -sL https://bit.ly/2F3CATp | bash
# # Edit alis-recovery.conf and change variables values with your last installation with alis
# vim alis-recovery.conf
# # Optional asciinema video
# ./alis-asciinema-recovery.sh
# ./alis-recovery.sh
```

### Video

[![asciicast](https://asciinema.org/a/192880.png)](https://asciinema.org/a/192880)

### Arch Linux Installation Media

https://www.archlinux.org/download/

### Reference

* https://wiki.archlinux.org/index.php/Installation_guide
* https://wiki.archlinux.org/index.php/Main_page
* https://wiki.archlinux.org/index.php/General_recommendations
* https://wiki.archlinux.org/index.php/List_of_applications
* https://wiki.archlinux.org/index.php/Intel_NUC
* https://wiki.archlinux.org/index.php/Network_configuration
* https://wiki.archlinux.org/index.php/Wireless_network_configuration
* https://wiki.archlinux.org/index.php/Wireless_network_configuration#Connect_to_an_access_point
* https://wiki.archlinux.org/index.php/NetworkManager
* https://wiki.archlinux.org/index.php/Solid_State_Drives
* https://wiki.archlinux.org/index.php/Solid_state_drive/NVMe
* https://wiki.archlinux.org/index.php/Partitioning
* https://wiki.archlinux.org/index.php/Fstab
* https://wiki.archlinux.org/index.php/Swap
* https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface
* https://wiki.archlinux.org/index.php/EFI_System_Partition
* https://wiki.archlinux.org/index.php/File_systems
* https://wiki.archlinux.org/index.php/Ext4
* https://wiki.archlinux.org/index.php/Persistent_block_device_naming
* https://wiki.archlinux.org/index.php/LVM
* https://wiki.archlinux.org/index.php/Dm-crypt
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption
* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
* https://wiki.archlinux.org/index.php/Pacman
* https://wiki.archlinux.org/index.php/Arch_User_Repository
* https://wiki.archlinux.org/index.php/Mirrors
* https://wiki.archlinux.org/index.php/VirtualBox
* https://wiki.archlinux.org/index.php/Mkinitcpio
* https://wiki.archlinux.org/index.php/Intel_graphics
* https://wiki.archlinux.org/index.php/AMDGPU
* https://wiki.archlinux.org/index.php/ATI
* https://wiki.archlinux.org/index.php/NVIDIA
* https://wiki.archlinux.org/index.php/Nouveau
* https://wiki.archlinux.org/index.php/Kernels
* https://wiki.archlinux.org/index.php/Kernel_mode_setting
* https://wiki.archlinux.org/index.php/Kernel_parameters
* https://wiki.archlinux.org/index.php/Category:Boot_loaders
* https://wiki.archlinux.org/index.php/GRUB
* https://wiki.archlinux.org/index.php/REFInd
* https://wiki.archlinux.org/index.php/Systemd-boot
* https://wiki.archlinux.org/index.php/Systemd
* https://wiki.archlinux.org/index.php/Microcode
* https://wiki.archlinux.org/index.php/Wayland
* https://wiki.archlinux.org/index.php/Xorg
* https://wiki.archlinux.org/index.php/Desktop_environment
* https://wiki.archlinux.org/index.php/GNOME
* https://wiki.archlinux.org/index.php/KDE
* https://wiki.archlinux.org/index.php/Xfce
* http://tldp.org/LDP/Bash-Beginners-Guide/html/
* http://tldp.org/LDP/abs/html/
