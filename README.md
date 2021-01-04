# alis

Arch Linux Install Script (or alis) installs unattended, automated and customized Arch Linux system.

It is a simple bash script that fully automates the installation of a Arch Linux system after booting from the original Arch Linux installation media. It contains the same commands that you would type and execute one by one interactively to complete the installation. The only user intervention needed is to edit a configuration file to choose the installation options and preferences from partitioning, to encryption, bootloader, file system, language and keyboard mapping, desktop environment, kernels, packages to install and graphic drivers. This automation makes the installation easy and fast.

If some time later after an system update for any reason the system does not boot correctly a recovery script is also provided to enter in a recovery mode that allows to downgrade packages or execute any other commands to restore the system. Also a log of the installation can be taken with <a href="https://asciinema.org/">asciinema</a>.

**Warning! This script can delete all partitions of the persistent storage. It is recommended to test it first in a virtual machine like <a href="https://www.virtualbox.org/">VirtualBox</a>.**

Currently these scripts are for me but maybe they are useful for you too.

Follow the [Arch Way](https://wiki.archlinux.org/index.php/Arch_Linux) of doing things and learn what this script does. This will allow you to know what is happening. 

Please, don't ask for support for this script in Arch Linux forums, first read the [Arch Linux wiki](https://wiki.archlinux.org), the [Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide) and the [General Recommendations](https://wiki.archlinux.org/index.php/General_recommendations), later compare those commands with the commands of this script.

For new features, improvements and bugs fill an issue in GitHub or make a pull request. You can test it in a [VirtualBox](https://www.virtualbox.org/) virtual machine (strongly recommended) before run it in real hardware. If you test it in real hardware please send me an email to pico.dev@gmail.com with the machine description and tell me if something goes wrong or all works fine. [Pull request](https://github.com/picodotdev/alis/pulls) and [new feature request](https://github.com/picodotdev/alis/issues) are welcome!

**Arch Linux Install Script (alis) is based on Arch Linux but is NOT approved, sponsored, or affiliated with Arch Linux or its related projects.**

[![Arch Linux](https://picodotdev.github.io/alis/images/logos/archlinux.svg "Arch Linux")](https://www.archlinux.org/)

### Index

* [Donations](https://github.com/picodotdev/alis#donations)
* [Principles](https://github.com/picodotdev/alis#principles)
* [Features](https://github.com/picodotdev/alis#features)
* [System installation](https://github.com/picodotdev/alis#system-installation)
* [Packages installation](https://github.com/picodotdev/alis#packages-installation)
* [Recovery](https://github.com/picodotdev/alis#recovery)
* [How you can help](https://github.com/picodotdev/alis#how-you-can-help)
* [Test in VirtualBox with Packer](https://github.com/picodotdev/alis#test-in-virtuabox-with-packer)
* [Video](https://github.com/picodotdev/alis#video)
* [Arch Linux Installation Media](https://github.com/picodotdev/alis#arch-linux-installation-media)
* [Reference](https://github.com/picodotdev/alis#reference)

### Donations

If you find useful this script, you can support me with a [small donation](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3PF47D5TSNL7C&currency_code=EUR) through PayPal to continue adding features, updating the script, accepting pull request and responding to any question. Also there are other ways you can contribute in the [How you can help](https://github.com/picodotdev/alis#how-you-can-help) section.

[![Donate with PayPal button](https://www.paypalobjects.com/en_US/ES/i/btn/btn_donateCC_LG.gif "PayPal - The safer, easier way to pay online!")](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3PF47D5TSNL7C&currency_code=EUR)

### Principles

* Use the original Arch Linux installation media
* As much unattended and automated as possible, require as little interactivity as possible
* Allow to customize the installation to cover the most common cases
* Provide support for system recovery
* Provide support for installation log

### Features

* **System**: UEFI, BIOS
* **Storage**: SATA, NVMe and MMC
* **Encryption**: root partition encrypted and no encrypted
* **Partition**: no LVM, LVM, LVM on LUKS, GPT on UEFI, MBR on BIOS
* **File system**: ext4, btrfs (with subvols), xfs, f2fs, reiserfs
* **Kernels**: linux, linux-lts, linux-hardened, linux-zen
* **Desktop environment**: GNOME, KDE, XFCE, Mate, Cinnamon, LXDE, i3-wm, i3-gaps
* **Display managers**: GDM, SDDM, Lightdm, lxdm
* **Graphics controller**: intel, nvidia and amd with optionally early KMS start. With intel optionally fastboot, hardware video acceleration and framebuffer compression.
* **Bootloader**: GRUB, rEFInd, systemd-boot
* **Custom shell**: bash, zsh, dash, fish
* **WPA WIFI network** installation
* **Periodic TRIM** for SSD storage
* Intel and AMD **processors microcode**
* Optional **swap file**
* **VirtualBox guest additions**
* **Kernel compression** and **custom parameters**
* **Users creation** and **add to sudoers**
* **systemd units enable or disable**
* **Multilib** support
* **Arch Linux** common and custom **packages installation**
* Flatpak utility installation and **Flatpak packages installation**
* SDKMAN utility installation and **SDKMAN packages installation**
* **AUR utility** installation (yay, aurman) and **AUR packages installation**
* **Packages installation after base system installation** (preferred way of packages installation)
* Script for download installation and **recovery scripts** and configuration files
* **Retry packages download** on connection/mirror error
* **Packer support** for testing in VirtualBox
* **Installation log** with all commands executed and output in a file and/or **asciinema video**
* Wait after installation for an **abortable reboot**
* Fork the repository and **use your own configuration**

### System installation

Download and boot from the latest <a href="https://www.archlinux.org/download/">original Arch Linux installation media</a>. After boot use the following commands to start the installation.

Follow the <a href="https://wiki.archlinux.org/index.php/Arch_Linux">Arch Way</a> of doing things and learn what this script does. This will allow you to know what is happening. 

Internet connection is required, with wireless WIFI connection see <a href="https://wiki.archlinux.org/index.php/Wireless_network_configuration#Wi-Fi_Protected_Access">Wireless_network_configuration</a> to bring up WIFI connection before start the installation.

```
#                         # Start the system with latest Arch Linux installation media
# loadkeys [keymap]       # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
# curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/2F3CATp | bash                                                 # Alternative download URL with URL shortener
# ./alis-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis.conf           # Edit configuration and change variables values with your preferences (system configuration)
# vim alis-packages.conf  # (Optional) Edit configuration and change variables values with your preferences (packages to install)
#                         # (The preferred way to install packages is after system installation, see Packages installation)
# ./alis.sh               # Start installation
# ./alis-reboot.sh        # (Optional) Reboot the system, only necessary when REBOOT="false"
```

If you fork _alis_ repository you can host your own configuration and changes in your repository.

```
# curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash -s -- -u [github user]
```

### Packages installation

After the base Arch Linux system is installed, alis can install packages with pacman, Flatpak, SDKMAN and from AUR.

```
#                                  # After system installation start a user session
# curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/2F3CATp | bash                                                 # Alternative download URL with URL shortener
# ./alis-packages-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis-packages.conf           # Edit configuration and change variables values with your preferences (packages to install)
# ./alis-packages.sh               # Start packages installation
```

### Recovery

Boot from the latest <a href="https://www.archlinux.org/download/">original Arch Linux installation media</a>. After boot use the following commands to start the recovery, this will allow you to enter in the arch-chroot environment.

```
#                                  # Start the system with latest Arch Linux installation media
# loadkeys [keymap]                # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
# curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# # curl -sL https://bit.ly/2F3CATp | bash                                                 # Alternative download URL with URL shortener
# ./alis-recovery-asciinema.sh     # (Optional) Start asciinema video recording
# vim alis-recovery.conf           # Edit configuration and change variables values with your last installation configuration with alis (mainly device and partition scheme)
# ./alis-recovery.sh               # Start recovery
# ./alis-recovery-reboot.sh        # Reboot the system
```

### How you can help

* Test in VirtualBox and create an issue if something does not work, attach the main parts of the used configuration file and the error message
* Create issues with new features
* Send pull requests
* Share it in social networks, forums, create a blog post or video about it
* Send me an email, I like to read that the script is being used and is useful :). Which are your computer specs, which is your alis configuration, if is your personal or working computer, if all worked fine or some suggestion to improve the script
* Consider to make a [small donation](https://github.com/picodotdev/alis#donations)

### Test in VirtualBox with Packer

VirtualBox and [Packer](https://packer.io/) are required.

* Firmware: efi, bios
* File system: ext4, btrfs, f2fs, xfs
* Partition: luks, lvm
* Bootloader: grub, refind, systemd
* Desktop environment: gnome, kde, xfce, ...

```
$ ./alis-packer.sh -c alis-packer-efi-ext4-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-systemd-gnome.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-luks-lvm-grub.sh
$ ./alis-packer.sh -c alis-packer-efi-btrfs-luks-lvm-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-f2fs-luks-lvm-systemd.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-gnome.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-kde.sh
$ ./alis-packer.sh -c alis-packer-efi-ext4-grub-xfce.sh
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
* https://wiki.archlinux.org/index.php/Btrfs
* https://wiki.archlinux.org/index.php/XFS
* https://wiki.archlinux.org/index.php/F2FS
* https://wiki.archlinux.org/index.php/Persistent_block_device_naming
* https://wiki.archlinux.org/index.php/LVM
* https://wiki.archlinux.org/index.php/Dm-crypt
* https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption
* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
* https://wiki.archlinux.org/index.php/Pacman
* https://wiki.archlinux.org/index.php/Arch_User_Repository
* https://wiki.archlinux.org/index.php/Mirrors
* https://wiki.archlinux.org/index.php/Reflector
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
* https://wiki.archlinux.org/index.php/Command-line_shell
* https://wiki.archlinux.org/index.php/Wayland
* https://wiki.archlinux.org/index.php/Xorg
* https://wiki.archlinux.org/index.php/Desktop_environment
* https://wiki.archlinux.org/index.php/GNOME
* https://wiki.archlinux.org/index.php/KDE
* https://wiki.archlinux.org/index.php/Xfce
* https://wiki.archlinux.org/index.php/I3
* http://tldp.org/LDP/Bash-Beginners-Guide/html/
* http://tldp.org/LDP/abs/html/
