---
title: "alis :. Arch Linux Install Script"
url: "/"
---

<div class="hero-body">
  <div class="container">
    <div class="columns is-vcentered">
      <div class="column is-10 is-offset-1 landing-caption">
        <h1 class="title is-1 is-size-x5 is-bold is-spaced has-text-centered">
          Arch Linux Install Script
        </h1>
        <h2 class="subtitle is-3 is-muted has-text-centered">
          An easy and fast way to install Arch Linux.
          <br>
          Boot. Get. Configure. Install. Enjoy.
        </h2>
        <p class="has-text-centered">
          <a class="button cta primary-btn raised" href="#installation">
            How to install
          </a>
          <a class="button cta primary-btn raised" href="#video">
            See it in video
          </a>
        </p>
      </div>
    </div>
  </div>
</div>

<div class="hero-body">
  <div class="container">
    <div class="columns is-vcentered">
    <div class="column is-6 is-offset-3 has-text-centered">
      <figure class="image">
        <a href="https://www.archlinux.org/"><img src="images/logos/archlinux.svg" alt="Arch Linux"></a>
      </figure>
    </div>
  </div>
</div>

<section id="whaisit" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">What is it?</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <p>
        Arch Linux Install Script (or alis) installs unattended, automated and customized Arch Linux system.
      </p>
      <p>
        It is a simple bash script that fully automates the installation of a Arch Linux system after booting from the original Arch Linux installation media. It contains the same commands that you would type and execute one by one interactively to complete the installation. The only user intervention needed is to edit a configuration file to choose the installation options and preferences from partitioning, to encryption, bootloader, file system, language and keyboard mapping, desktop environment, kernels, packages to install and graphic drivers. This automation makes the installation easy and fast.
      </p>
      <p>
        If some time later after an system update for any reason the system does not boot correctly a recovery script is also provided to enter in a recovery mode that allows to downgrade packages or execute any other commands to restore the system. Also a log of the installation can be taken with <a href="https://asciinema.org/">asciinema</a>.
      </p>
      <p class="has-text-danger">
        Warning! This script can delete all partitions of the persistent storage. It is recommended to test it first in a virtual machine like <a href="https://www.virtualbox.org/">VirtualBox</a>.
      </p>
    </div>
  </div>
</section>

<section id="principles" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Principles</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <ul>
        <li>Use the original Arch Linux installation media</li>
        <li>Require as little interactivity as possible</li>
        <li>Allow to customize the installation to cover the most common cases</li>
        <li>Provide support for recovery</li>
        <li>Provide support for log</li>
      </ul>
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
        <li>System: GPT, UEFI, BIOS</li>
        <li>Storage: SATA, NVMe and MMC</li>
        <li>Encryption: root partition encrypted and no encrypted</li>
        <li>Partition: no LVM, LVM, LVM on LUKS</li>
        <li>File system: ext4, btrfs (with subvols), xfs</li>
        <li>Optional file swap (not supported in btrfs)</li>
        <li>Storage: SATA, NVMe and MMC</li>
        <li>Kernels: linux-lts, linux-hardened, linux-zen</li>
        <li>Desktop environment: GNOME, KDE, XFCE, Mate, Cinnamon, LXDE</li>
        <li>Display managers: GDM, SDDM, Lightdm, lxdm</li>
        <li>Graphics controller: intel, nvidia, amd with optionally early KMS start</li>
        <li>Bootloader: GRUB, rEFInd, systemd-boot</li>
        <li>Periodic TRIM for SSD storage</li>
        <li>Intel and AMD processors microcode</li>
        <li>Optional file swap (not supported in btrfs)</li>
        <li>VirtualBox guest utils</li>
        <li>WPA WIFI network installation</li>
        <li>Kernel compression and custom parameters</li>
        <li>Users creation and add to sudoers</li>
        <li>Common and custom packages installation</li>
        <li>AUR utility installation (aurman, yay)</li>
        <li>Script for download installation and recovery scripts and configuration files</li>
        <li>Retry packages download on connection/mirror error</li>
        <li>Packer support for testing in VirtualBox</li>
        <li>Installation log with all commands executed and output in a file and/or asciinema video</li>
        <li>Wait after installation for an abortable reboot</li>
      </ul>
    </div>
  </div>
</section>

<section id="installation" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Installation</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
      <p>
        Download and boot from the latest <a href="https://www.archlinux.org/download/">original Arch Linux installation media</a>. After boot use the following commands to start the installation.
      </p>
      <p>
        Follow the <a href="https://wiki.archlinux.org/index.php/Arch_Linux">Arch Way</a> of doing things and learn what this script does. This will allow you to know what is happening. 
      </p>
      <p>
      Internet connection is required, with wireless WIFI connection see <a href="https://wiki.archlinux.org/index.php/Wireless_network_configuration#Wi-Fi_Protected_Access">Wireless_network_configuration</a> to bring up WIFI connection before start the installation.
      </p>
{{< highlight bash "" >}}
# Load keymap
loadkeys [keymap]
# Download alis directly or with url shortener
curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
curl -sL https://bit.ly/2F3CATp | bash
# Edit alis.conf and change variables values with your preferences
vim alis.conf
# Start
./alis.sh
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
       <script type="text/javascript" src="https://asciinema.org/a/192880.js" data-size="medium" data-cols="160" data-rows="40" id="asciicast-192880" async></script>
    </div>
  </div>
</section>


<section id="installation-log" class="section is-medium">
  <div class="container">
    <div class="title-wrapper has-text-centered">
      <h2 class="title is-2">Installation with log</h2>
      <div class="divider is-centered"></div>
    </div>
    <div class="content-wrapper">
{{< highlight bash "" >}}
# Load keymap
loadkeys [keymap]
# Download alis directly or with url shortener
curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
curl -sL https://bit.ly/2F3CATp | bash
./alis-asciinema.sh
# Edit alis.conf and change variables values with your preferences
vim alis.conf
# Start
./alis.sh
# Exit
exit
./alis-reboot.sh
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
# Load keymap
loadkeys [keymap]
# Download alis directly or with url shortener
curl https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
curl -sL https://bit.ly/2F3CATp | bash
# Edit alis-recovery.conf and change variables values with your last installation with alis
vim alis-recovery.conf
# Start
./alis-recovery.sh
{{< / highlight >}}
    </div>
  </div>
</section>

<section id="howyoucanhelp" class="section is-medium">
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
      </ul>
    </div>
  </div>
</section>
