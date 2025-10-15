---
pid: 1
title: "Overview"
type: "pages"
url: "/overview/"
date: 2022-02-10T19:00:00+01:00
updated: 2022-02-10T16:30:00+01:00
index: true
tags: []
---

<section class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col">
        {{< ad-bilboard >}}
      </div>
    </div>
  </div>
</section>

# Overview

The [Arch Linux](https://archlinux.org/) distribution can be intimidating for users who want to use it as it does not offer a graphical installer and the officially recommended option is to read a few dozen pages of the wiki to complete the installation and then type many commands interactively from the terminal in which the installation media is launched. An installer is not offered because one of the principles of Arch is that it adjusts to the user and not the user to Arch, with an installer it is very difficult or impossible to achieve the customization desired by all users, that is why it is left to each user the responsibility but the power to install it as you want according to your preferences.

Actually it is not complicated to install Arch Linux in a basic configuration including a desktop environment but some options have a little more complexity and sometimes it is not achieved on the first try or it is achieved but not done correctly. For example, using LUKS over LVM to encrypt storage are additional steps in the installation that may cause the system to fail to boot properly using a boot loader such as systemd-boot or a user is not aware of the need to enable support for TRIM of the SSD device to keep it in optimal performance and durability conditions.

In any case, reading the wiki pages and finishing the installation successfully requires time and some effort to acquire the necessary knowledge, this makes Arch-based distributions with a graphical installer an alternative for those who want a distro like Arch Linux but installing it easily and quickly. However, some Arch-based distributions add their own customizations are no longer considered an Arch Linux distribution but a derivative distribution.

{{< tableofcontents >}}

### Introduction to Arch Linux

A user who is interested in must be aware of [the Arch Linux principles](https://wiki.archlinux.org/title/Arch_Linux#Principles) on which it is based, also known unofficially as _The Arch Way_, which are stated as _Simplicity_, _Modernity_, _Pragmatism_, _User centrality_ and _Versatility_. They can be summarized in that Arch Linux provides packages with minimal customizations over the original software, it is a _rolling-release_ distribution in which the packages are constantly updated to the latest versions, decisions are based on technical aspects, generally offering free software and open source without excluding proprietary software for those users who require that functionality, it is a user-centric rather than user-friendly distribution, it is intended for competent GNU/Linux users or anyone with an attitude that is willing to read documentation and solve their own problems. Finally, it is a general purpose distribution that not installs unwanted packages.

Once these principles and some of its characteristics are known, if you think that Arch Linux suits your needs, it is time to install. The official way to install Arch Linux is through the [official installation guide](https://wiki.archlinux.org/title/Installation_guide) that is made up of a collection of wiki pages that explain each step together with the commands to execute one after the other on the terminal in which the installation media starts. Installing Arch Linux manually and after reading the various necessary wiki pages you learn and know in more detail various aspects of the installed system, this is a great way to learn many things.

In addition to the principles, another way to see how Arch Linux differs from other distributions is that it is a rolling release distribution, so that in each system update, all the packages and programs are updated to the latest versions. That Arch is a rolling release distribution does not mean it is unstable, on the contrary, it is a very stable distribution that does not usually cause problems and, generally, if they do occur, they are minor and corrected in the next version of the package that presents the bad behavior. For the rare occasions in which there is a serious problem in which the system does not start until the graphic environment and in case it is not possible to restore the proper functioning of the system, it is always recommended to make backup copies so not to lose any important data.

Another relevant aspect is its the great [Arch Linux wiki](https://wiki.archlinux.org/) knowledge base, broken down into topics with enough detail to learn, install, get started, and resolve common known issues. The necessary commands for all of this are included in the wiki pages.

If the wiki is not enough, there are the official discussion [forums](https://bbs.archlinux.org/), to request and offer help to other users of the distribution. Another source of help and information is the [Arch Linux Reddit](https://www.reddit.com/r/archlinux/) channel where you can read and write comments for other users of the distribution, sometimes about help, conversations or news related to Arch.

### The alis script to install Arch Linux

Installing Arch Linux manually allows you to know the installed system in detail, however, reading several dozen pages of the wiki requires time and performing the manual installation is slow with the possibility of making mistakes. The first manual installations of Arch Linux is didactic but it is tedious for users who already know how to do it and simply want to install the system in a short time or without discovering new small steps that have changed over time since the last installation. Luckily, Arch Linux, being a rolling release distribution, and unless the system fails for some reason or you want to make a fundamental change to the system, an installation allows you to keep the system running for years, fully updated with regular system updates every few weeks.

Each Arch Linux user may have his own recipe with the list of commands compiled to perform the installation according to his preferences. Some of these users find it convenient to create a script for personal use to automate the installation. A few of those users share their script in case it is useful to other users. In the absence of an official installer the result is that there are several unofficial user-developed scripts available to perform the installation easily, [arch-install](https://github.com/archlinux/archinstall) and [archfi](https://github.com/MatMoul/archfi/) are two examples.

Another script to install Arch Linux is this one where you are, [alis](https://github.com/picodotdev/alis). Arch Linux Install Script or alis is a script to install a pure Arch Linux from official installation media.

### Motivation

alis is a personal project that arises just like other projects and scripts. The existing scripts that I knew of to install Arch Linux were not flexible enough or ware interactive so at the time I was going to need to install Arch Linux on my next personal computer I was going to use, an Intel NUC, I started creating the script that I wanted but didn't exist.

The goal of alis is to make an Arch Linux installation as fast as possible and flexible enough to be able to install Arch with the most common options that most users want. Even so, since the flexibility of Arch Linux is so great that it is almost impossible to cover all the possible configurations and perform the installation to leave it just as a user wants. alis allows to install a system with the most common and fundamental system options and once installed the user can customize the installation according to the less important specific preferences. Even the installation of packages in alis although it is possible, I recommend installing them after the base installation, because it is more reliable than doing it during the installation, especially some AUR packages that are prone to not compiling well or to fail in the installation.

To satisfy these two properties of speed and flexibility, it is necessary for the script to be unattended, since being guided makes the interaction with the text or graphic interface easier than typing the commands in the terminal, but it is still slow, repetitive and tedious. Also a guided installer would be too complex to cover all possible customization options and if it is very simple it only offers a small part of all the options that users want.

Surely there are many users who, still wanting to install Arch or happy with Arch, switch to another distribution or another Arch derivative distribution for the simple fact that they have a graphical, guided and automated installer after some clicks.

It is a personal project that I keep in my spare time, keep in mind when asking for help or some new feature that you want. If it works for you that is perfect, and if not, send a pull request to GitHub so I can review it and if it improves the script and is useful for other users I will be happy to merge it.

alis is intended both for newcomers to facilitate the task or simply to serve as an executable guide to the commands that he obtains from the wiki. It is also intended for advanced users to avoid the tedious work of performing the installation manually or in a virtual machine, making the installation repeatable and not spending another significant amount of time on each new installation.

I do my best to keep it reliable and fix errors but do not expect it to be perfect and completely error free. Arch is a rolling release distro and things change, I do not have time to try all the possible combinations at all times, so before using it in real hardware try it in a virtual machine.

### Principles

The principles on which alis is based are the following:

* Use the original Arch Linux installation media
* As much unattended and automated as possible, require as little interactivity as possible
* Allow to customize the installation to cover the most common cases
* Provide support for system recovery
* Provide support for installation log
* Use sane configuration default values

I did not want to create a new installation media because it requires a repository to store it and by security concerns so alis is downloaded once booted from the original installation media which authenticity can be checked with a hash algorithm. To use alis only requires four commands to be typed and tweak some configuration variables to easily customize the installation to cover the most common cases. The configuration has sane defaults and allows you to choose more advanced features.

Generally it is not needed to start a recovery but when after an update something serious happens it is necessary to recover the system to a working state, maybe downgrading packages. Also is almost unattended, it allows to collect all the script output to a log including to capture the output to an [asciinema](https://asciinema.org/) video to review after installation if needed.

#### Bash based

alis is a script based on the Bash shell. Contains the same commands you type on a manual install one after another. Being Bash based is easy to compare the script commands with your own manual recipe and easy to compare with the commands provided by the Arch Linux wiki pages and other installation guides. Although alis is not used can serve as a guide and documentation to do some specific tasks, because that can be known as _the Arch Linux executable installation guide and wiki_.

#### Simple configuration

The configuration is a simple Bash file that defines some environment variables to customize the installation to each user's own preferences. Simple variables but that allow most common and quite advanced configurations.

Customizing the installation simply consists of changing the values of the variables for which many of them are already provided as predefined options to choose from. Other variables require the user to enter the exact values that he wants. Editing the configuration file can be done after downloading alis before starting the unattended installation but the configuration can also be downloaded from the internet as a personal GitHub repository and used multiple times.

#### Unattended

Fully automated to complete the installation easy and fast, as fast as your internet connection allows. Not a guided script means it is not necessary to spend time on answer slowly the same questions over and over on each usage.

If the script were guided it would be much more complex to create some kind of text-based interface and much more so if it were graphical. The script being guided would be much more complex and yet would certainly offer a few fewer customization options.

Being a script that I develop in my personal time, being simple is a must and allow new features to be added with the minimal work is essential for it to be maintainable.

#### Desktop environments

The most popular GNU/Linux desktop environments are [GNOME](https://www.gnome.org/), [KDE](https://kde.org/), [XFCE](https://xfce.org/) but also there are many other alternative graphical environments options like [i3-gap](https://github.com/Airblader/i3), [Deepin](https://www.deepin.org/en/dde/), [Budgie](https://github.com/BuddiesOfBudgie/budgie-desktop) and others. alis supports more than 10 environments.

#### Advanced features

Using some advanced features of a system requires additional configuration. Some are likely to be the standard in a few years like [PipeWire](https://pipewire.org/) server for audio and video likely to replace Pulseaudio sound server in most distributions, same for BTRFS file system with subvolumes as replacement for ext4, systemd-boot as loader boot instead of Grub, systemd-homed to make user directories portable and system-independent. In addition, alis offers support for installation via SSH with cloud-init, which is very useful for installing and automating it also on local virtual machines or in the cloud.

#### And much more!

But alis offers many more options like support for systems with BIOS or UEFI, different combinations of partitions with or without LVM and LUKS, different file systems like ext4, btrfs (with subvols), xfs, f2fs, reiserfs, the installation of additional kernels with the possibility of adding boot parameters in the configuration or compression programs for the initramfs, graphics drivers for Intel, AMD, and Nvidia, various boot loaders, customizing the command line interpreter between bash, zsh, dash or fish and support for installing packages during or after the base system install from the Arch Linux and AUR repositories, from Flatpak, or from SDKMAN.

In addition to other features such as support for TRIM on SSD drives to keep them in optimal working order, microcode for Intel and AMD processors, optionally swap with file, file provisioning to provide some configuration file among a few others. 

### How you can collaborate

If you use alis and find it useful, there are several ways you can collaborate and give something back in exchange for using the script. Some very simple ones that do not require much effort is to share it on social networks or forums when other users ask for help installing Arch Linux. If you have a blog you can also write an article or if you have a YouTube channel upload a video so that other users when they look for information on how to install Arch Linux quickly and easily find the script in one way or another.

If you make a change to the script and it is interesting for other users, you can send me a pull request so that I can merge it and in this way you do not have to keep the change in your fork. You can also create a issue or open a [discussion](https://github.com/picodotdev/alis/discussions) thread on GitHub.

The above are already great ways to contribute to the script and enough, seeing what is used and useful helps me keep interested in further developing it, fixing bugs, updating and adding new features. If the script has been very useful to you and you want to thank the work also with a small economic donation, especially if you use it in a work or business environment, you can do it through [PayPal](https://www.paypal.com) to my associated PayPal email address [pico.dev@gmail.com](mailto:pico.dev@gmail.com).

### How to submit bug reports and request changes

An Arch Linux user when he has an error or a problem should try first to solve the problem himself, with the help of the wiki and searching for information with an internet search engine. And finally, if you are not able to solve the problem yourself, then ask other users for information. In order for other people to be able to provide you with help quickly and effectively, it is necessary that you describe the problem in detail and provide as much relevant information as possible, sometimes an image is better or complements the description.

The source code repository is hosted on GitHub, which also allows you to create issues with requests for changes or bug fixes, but the best thing is that if you can send a pull request that I will review and if it is useful I will apply to the source code of alis. The changes and new features should be useful to other users as well.

### Other alternatives

There are other quite good similar projects that can be used as alternative to install a pure Arch Linux without any additions.

* [Arch Installer](https://github.com/archlinux/archinstall) (archinstall) (maybe is the most relevant as is included in the official installation media)
* [archfi](https://github.com/MatMoul/archfi/)
* [Archlinux Ultimate Installer (aui)](https://github.com/helmuthdu/aui) (only accepts patches)

Also, if you prefer to install an Arch Linux using a guided graphical installer you can choose an Arch based distribution.

* [ArcoLinux](https://arcolinux.com/)
* [Manjaro](https://manjaro.org/)
* [EndeavourOS](https://endeavouros.com/)
* [Archlabs](https://archlabslinux.com/)
* [RebornOS](https://rebornos.org/)
* [BlackArch](https://blackarch.org/)

Also and recomended for new Arch Linux new comers follow the Arch Way of doing things is a good way to use and learn about Arch. There are many guides out here, the official Arch Linux installation guide the first one. These are other good ones that explains step by step from instalation media creation to first boot and programs installation, all the necessary to start.

* [The Arch Linux Handbook](https://www.freecodecamp.org/news/how-to-install-arch-linux/)

<section class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col">
        {{< ad-bilboard >}}
      </div>
    </div>
  </div>
</section>