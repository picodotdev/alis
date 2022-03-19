---
pid: 3
title: "Istallation :. Arch Linux Install Script"
type: "pages"
url: "/installation/"
date: 2022-02-04T16:00:00+01:00
updated: 2022-02-04T16:00:00+01:00
index: true
rss: true
sharing: true
imagePage: "logotype:octopress.png"
tags: []
draft: true
---

# Installation


<section id="principles">
  <div class="container">
    <div class="row">
      <div class="col">
        <h2 class="fs-3 fw-bold">Principles</h2>
{{< markdown >}}
* Use the original Arch Linux installation media
* As much unattended and automated as possible, require as little interactivity as possible
* Allow to customize the installation to cover the most common cases
* Provide support for system recovery
* Provide support for installation log
{{< /markdown >}}
      </div>
    </div>
  </div>
</section>

<section id="features" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Features</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <ul>
        <li><b>System</b>: UEFI, BIOS</li>
        <li><b>Storage</b>: SATA, NVMe and MMC</li>
        <li><b>Encryption</b>: root partition encrypted and no encrypted</li>
        <li><b>Partition</b>: no LVM, LVM, LVM on LUKS, GPT on UEFI, MBR on BIOS, custom partition scheme and mountpoints</li>
        <li><b>File system</b>: ext4, btrfs (with subvols), xfs, f2fs, reiserfs</li>
        <li><b>Kernels</b>: linux, linux-lts, linux-hardened, linux-zen</li>
        <li><b>Desktop environment</b>: GNOME, KDE, XFCE, Mate, Cinnamon, LXDE, i3-wm, i3-gaps, Deepin, Budgie, Bspwm, Awesome, Qtile, Openbox</li>
        <li><b>Display managers</b>: GDM, SDDM, Lightdm, lxdm</li>
        <li><b>Graphics controller</b>: intel, nvidia and amd with optionally early KMS start. With intel optionally fastboot, hardware video acceleration and framebuffer compression.</li>
        <li><b>Bootloader</b>: GRUB, rEFInd, systemd-boot</li>
        <li><b>Custom shell</b>: bash, zsh, dash, fish</li>
        <li><b>WPA WIFI network</b> installation</li>
        <li><b>Periodic TRIM</b> for SSD storage</li>
        <li>Intel and AMD </b>processors microcode</b></li>
        <li>Optional <b>swap file</b></li>
        <li><b>VirtualBox guest additions</b> and <b>VMware tools</b> support</li>
        <li><b>Kernel compression</b> and <b>custom parameters</b></li>
        <li><b>Users creation</b> and <b>add to sudoers</b></li>
        <li><b>systemd units enable or disable</b></li>
        <li><b>systemd-homed</b> support</li>
        <li><b>PipeWire</b> support</li>
        <li><b>Multilib</b> support</li>
        <li><b>Files provision</b> support</li>
        <li>Arch Linux custom <b>packages installation</b> and <b>repositories installation</b></li>
        <li>Flatpak utility installation and <b>Flatpak packages installation</b></li>
        <li>SDKMAN utility installation and <b>SDKMAN packages installation</b></li>
        <li><b>AUR utility</b> installation (yay, aurman) and <b>AUR packages installation</b></li>
        <li><b>Packages installation after base system installation</b> (preferred way of packages installation)</li>
        <li>Script for download installation and <b>recovery scripts</b> and configuration files</li>
        <li><b>Retry packages download</b> on connection/mirror error</li>
        <li><b>Packer support</b> for testing in VirtualBox</li>
        <li><b>Installation log</b> with all commands executed and output in a file and/or <b>asciinema video</b></li>
        <li>Wait after installation for an <b>abortable reboot</b></li>
        <li>Fork the repository and <b>use your own configuration</b></li>
      </ul>
  </div>
</section>

<section id="system-installation" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">System installation</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <p>
        Download and boot from the latest <a href="https://www.archlinux.org/download/">original Arch Linux installation media</a>. After boot use the following commands to start the installation.
      </p>
      <p>
        Follow the <a href="https://wiki.archlinux.org/title/Arch_Linux">Arch Way</a> of doing things and learn what this script does. This will allow you to know what is happening.
      </p>
      <p>
      Internet connection is required, with wireless WIFI connection see <a href="https://wiki.archlinux.org/title/Wireless_network_configuration#Wi-Fi_Protected_Access">Wireless_network_configuration</a> to bring up WIFI connection before start the installation.
      </p>
      <p>
        Minimum usage
      </p>
{{< highlight bash "" >}}
                        # Start the system with latest Arch Linux installation media
loadkeys [keymap]       # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
vim alis.conf           # Edit configuration and change variables values with your preferences (system configuration)
./alis.sh               # Start installation
{{< / highlight >}}
      <p>
        Advanced usage
      </p>
{{< highlight bash "" >}}
                        # Start the system with latest Arch Linux installation media
loadkeys [keymap]       # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# curl -sL https://git.io/JeaH6 | bash                                                   # Alternative download URL with URL shortener
./alis-asciinema.sh     # (Optional) Start asciinema video recording
vim alis.conf           # Edit configuration and change variables values with your preferences (system configuration)
vim alis-packages.conf  # (Optional) Edit configuration and change variables values with your preferences (packages to install)
                        # (The preferred way to install packages is after system installation, see Packages installation)
./alis.sh               # Start installation
./alis-reboot.sh        # (Optional) Reboot the system, only necessary when REBOOT="false"
{{< / highlight >}}
    </div>
  </div>
</section>

<section id="video" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Video</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
       <p>Arch Linux base installation installed in <b>less than 4 minutes</b> with a fiber internet connection and a NVMe SSD. Don't trust me? See the video.</p>
       <script type="text/javascript" src="https://asciinema.org/a/444025.js" data-size="medium" data-cols="160" data-rows="40" id="asciicast-444025" async></script>
    </div>
  </div>
</section>

<section id="packages-installation" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Packages installation</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
    <p>
    After the base Arch Linux system is installed, alis can install packages with pacman, Flatpak, SDKMAN and from AUR.
    </p>
{{< highlight bash "" >}}
                                 # After system installation start a user session
curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# curl -sL https://git.io/JeaH6 | bash                                                   # Alternative download URL with URL shortener
./alis-packages-asciinema.sh     # (Optional) Start asciinema video recording
vim alis-packages.conf           # Edit configuration and change variables values with your preferences (packages to install)
./alis-packages.sh               # Start packages installation
{{< / highlight >}}
    </div>
  </div>
</section>

<section id="recovery" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Recovery</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <p>
      Boot from the latest <a href="https://www.archlinux.org/download/">original Arch Linux installation media</a>. After boot use the following comands to start the recovery, this will allow you to enter in the arch-chroot environment.
      </p>
{{< highlight bash "" >}}
                                 # Start the system with latest Arch Linux installation media
loadkeys [keymap]                # Load keyboard keymap, eg. loadkeys es, loadkeys us, loadkeys de
iwctl --passphrase "[WIFI_KEY]" station [WIFI_INTERFACE] connect "[WIFI_ESSID]"          # (Optional) Connect to WIFI network. _ip link show_ to know WIFI_INTERFACE.
curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash     # Download alis scripts
# curl -sL https://git.io/JeaH6 | bash                                                   # Alternative download URL with URL shortener
./alis-recovery-asciinema.sh     # (Optional) Start asciinema video recording
vim alis-recovery.conf           # Edit configuration and change variables values with your last installation configuration with alis (mainly device and partition scheme)
./alis-recovery.sh               # Start recovery
./alis-recovery-reboot.sh        # Reboot the system
{{< / highlight >}}
    </div>
  </div>
</section>

<section id="how-you-can-help" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">How you can help</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <ul>
        <li>Test in VirtualBox and create an issue if something does not work, attach the main parts of the used configuration file and the error message</li>
        <li><a href="https://github.com/picodotdev/alis/issues">Create issues</a> with new features</li>
        <li>Send <a href="https://github.com/picodotdev/alis/pulls">pull requests</a></li>
        <li>Share it in social networks, forums, create a blog post or video about it</li>
        <li>Send me an email, I like to read that the script is being used and is useful :). Which are your computer specs, which is your alis configuration, if is your personal or working computer, if all worked fine or some suggestion to improve the script</li>
      </ul>
    </div>
  </div>
</section>

<section id="media-reference" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Media reference</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <ul>
        <li>2022.01 <a href="https://www.arcolinuxiso.com/aa/">Arch + Alis, Arco Linux</a> (<a href="https://www.youtube.com/playlist?list=PLlloYVGq5pS7lMblPjiifVxxnMAqYzBU5">video playlist</a>)</li>
        <li>2020.07 <a href="https://r1ce.net/2020/07/07/arch-installer-alis/">Arch installer - alis</a></li>
        <li>2019.06 <a href="https://www.forbes.com/sites/jasonevangelho/2019/06/10/arch-linux-os-challenge-2-alternatives-install-gui-script-easy/">Arch Linux OS Challenge: Install Arch 'The Easy Way' With These 2 Alternative Methods</a></li>
      </ul>
    </div>
  </div>
</section>

<div class="container">
  <div class="columns is-vcentered">
    <div class="column is-8 is-offset-2 has-text-centered">
      <div class="col-12 adblock-container-billboard">
        <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3533636310991304" crossorigin="anonymous"></script>
        <!-- alis-auto-billboard -->
        <div class="adsense adsense-billboard">
          <ins class="adsbygoogle"
              style="display:block"
              data-ad-client="ca-pub-3533636310991304"
              data-ad-slot="8430508513"
              data-ad-format="auto"
              data-full-width-responsive="true"></ins>
          <script>
              (adsbygoogle = window.adsbygoogle || []).push({});
          </script>
        </div>
      </div>
    </div>
  </div>
</div>
