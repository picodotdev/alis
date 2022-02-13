---
pid: 0
title: "alis :. Arch Linux Install Script"
url: "/"
date: 2022-02-04T16:00:00+01:00
updated: 2022-02-04T16:00:00+01:00
index: true
tags: []
---

<div class="container">
  <div class="row">
    <div class="col-12">
      <div class="p-5">
        <div class="py-5 text-center">
          <h1>Arch Linux Install Script</h1>
          <p class="fs-3 text-muted">A simple powerful Bash based script for an unattended, easy and fast way to install Arch Linux.</p>
          <p class="fs-3 text-muted">Boot. Get. Configure. Install. Enjoy.</p>
          <ul class="list-unstyled list-inline">
            <li class="list-inline-item"><a href="#usage">Usage</a></li>
            <li class="list-inline-item"><a href="#video">See it in video</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="container mt-4">
  <div class="row justify-content-center">
    <div class="col-auto">
      <figure class="text-center">
        <a href="https://www.archlinux.org/"><img src="images/logotypes/archlinux-logo-dark.svg" width="400" alt="Arch Linux"></a>
      </figure>
    </div>
    <div class="col-auto">
      <figure class="text-center">
        <a href="https://www.gnu.org/software/bash/"><img src="images/logotypes/bash.svg" width="300" alt="Bash"></a>
      </figure>
    </div>
  </div>
  <div class="row justify-content-center">
    <div class="col-auto">
      <figure class="text-center">
        <a href="https://www.gnu.org/"><img src="images/logotypes/gnu.svg" width="150" alt="GNU"></a>
      </figure>
    </div>
    <div class="col-auto">
      <figure class="text-center">
        <a href="https://www.kernel.org/"><img src="images/logotypes/linux.svg" width="150" alt="Linux"></a>
      </figure>
    </div>
  </div>
</div>

<section id="what-is" class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col-12">
        <h2 class="fs-3 fw-bold">What is alis?</h2>
{{< markdown >}}
Arch Linux Install Script (or alis, also known as _the Arch Linux executable installation guide and wiki_) installs unattended, automated and customized Arch Linux system.

It is a simple Bash script developed from many Arch Linux Wiki pages that fully automates the installation of a [Arch Linux](https://archlinux.org/) system after booting from the original Arch Linux installation media. It contains the same commands that you would type and execute one by one interactively to complete the installation. The only user intervention needed is to edit a configuration file to choose the installation options and preferences from partitioning, to encryption, bootloader, file system, language and keyboard mapping, desktop environment, kernels, packages to install and graphic drivers. This automation makes the installation easy and fast, as fast as your internet connection allows.
{{< /markdown >}}
      </div>
    </div>
  </div>
</section>

<section id="higlights" class="mt-4">
  <div class="container">
    <div class="row justify-content-around">
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">Bash based</h5>
            <p class="card-text">Contains the same commands you type on a manual install one after another. Being Bash based is easy to compare the script commands with your own manual recipe and easy to compare with the commands provided by the Arch Linux wiki pages and other installation guides, ecause that can be known as _the Arch Linux executable installation guide and wiki_.</p>
            <a href="https://github.com/picodotdev/alis" class="card-link">Source code</a>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">Simple configuration</h5>
            <p class="card-text">The configuration is a simple Bash file that defines some environment variables to customize the installation to each user own preferences. Simple variables but that allow most common and quite advanced configurations.</p>
            <a href="https://github.com/picodotdev/alis/blob/master/alis.conf" class="card-link">Configuration file</a>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">Unattended</h5>
            <p class="card-text">Fully automated to complete the installation easy and fast, as fast as your internet connection allows. Not a guided script means is not necessary to spend time on answer slowly the same questions over and over on each usage.</p>
            <a href="#video" class="card-link">See the video</a>
          </div>
        </div>
      </div>
    </div>
    <div class="row justify-content-around mt-4">
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">Desktop environments</h5>
            <p class="card-text">Choose between the most popular GNU/Linux desktop environments like <a href="https://www.gnome.org/">GNOME</a>, <a href="https://kde.org/">KDE</a>, <a href="https://xfce.org/">XFCE</a> or discover and try alternative graphical environments options like <a href="https://github.com/Airblader/i3">i3-gap</a>, <a href="https://www.deepin.org/en/dde/">Deepin</a>, <a href="https://github.com/BuddiesOfBudgie/budgie-desktop">Budgie</a> and others. Pick one from more than 10 available environments.</p>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">Advanced features</h5>
            <p class="card-text">Based on more than 70 Arch Linux wiki pages to get a successful installation also for advanced features like LVM, LUKS encryption, BTRFS filesystem with subvolumes, alternative kernels, systemd-boot, systemd-homed, PipeWire, AUR utility or SSH install for virtual machines.</p>
          </div>
        </div>
      </div>
      <div class="col-lg-4 col-xs-12">
        <div class="card">
          <div class="card-body">
            <h5 class="card-title fw-bold">And much more!</h5>
            <p class="card-text">These are a small feature set selection provided by alis. Read the complete list.</p>
            <a href="https://github.com/picodotdev/alis#features" class="card-link">Full feature set list</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<section class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col-12">
        {{< ad-bilboard >}}
      </div>
    </div>
  </div>
</section>

<section id="usage" class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col-12">
        <h2 class="fs-3 fw-bold">Usage</h2>
        <p>Only 4 commands away to have a vanilla Arch Linux system.</p>
        {{< code file="install.sh" language="bash" options="" >}}
      </div>
    </div>
  </div>
</section>

<section id="video" class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col-12">
        <h2 class="fs-3 fw-bold">Video</h2>
        <p>Arch Linux base installation installed in less than 4 minutes with a fiber internet connection and a NVMe SSD. Don't trust? See the video.</p>
        <p>Type the system installation commands and wait to the installation complete. After a reboot the system is ready to use and customized with your choosen preferences.</p>
        <script type="text/javascript" src="https://asciinema.org/a/444025.js" data-size="medium" data-cols="160" data-rows="40" id="asciicast-444025" async></script>
      </div>
    </div>
  </div>
</section>

<section id="screenshots" class="mt-4">
  <div class="container">
    <div class="row">
      <div class="col-12">
        <h2 class="fs-3 fw-bold">Screenshots</h2>
        <p>Once the installation ends you have a ready to use system with your choosen preferences including all the free software latest version you wish to do produtive task from browsing, multimedia and office programs, to programming languages, compilers and server software and tools for creative and artistic tasks.</p>
        <p>These are some desktop environments that can be installed.</p>
        <div class="p-5">
          <div id="desktopEnvironmentsCarousel" class="carousel slide" data-bs-ride="carousel">
            <div class="carousel-indicators">
              <button type="button" data-bs-target="#desktopEnvironmentsCarousel" data-bs-slide-to="0" class="active" aria-current="true" aria-label="GNOME"></button>
              <button type="button" data-bs-target="#desktopEnvironmentsCarousel" data-bs-slide-to="1" aria-label="KDE"></button>
              <button type="button" data-bs-target="#desktopEnvironmentsCarousel" data-bs-slide-to="2" aria-label="XFCE"></button>
            </div>
            <div class="carousel-inner">
              <div class="carousel-item active" data-bs-interval="10000">
                <img src="images/archlinux-gnome.jpg" class="d-block w-100" alt="Arch Linux with GNOME desktop environment installed with alis">
                <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50">
                  <h5>Arch Linux with GNOME desktop environment installed with alis</h5>
                </div>
              </div>
              <div class="carousel-item" data-bs-interval="10000">
                <img src="images/archlinux-kde.jpg" class="d-block w-100" alt="Arch Linux with KDE desktop environment installed with alis">
                <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50">
                  <h5>Arch Linux with KDE desktop environment installed with alis</h5>
                </div>
              </div>
              <div class="carousel-item" data-bs-interval="10000">
                <img src="images/archlinux-xfce.jpg" class="d-block w-100" alt="Arch Linux with XFCE desktop environment installed with alis">
                <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50">
                  <h5>Arch Linux with XFCE desktop environment installed with alis</h5>
                </div>
              </div>
            </div>
            <button class="carousel-control-prev" type="button" data-bs-target="#desktopEnvironmentsCarousel" data-bs-slide="prev">
              <span class="carousel-control-prev-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Previous</span>
            </button>
            <button class="carousel-control-next" type="button" data-bs-target="#desktopEnvironmentsCarousel" data-bs-slide="next">
              <span class="carousel-control-next-icon" aria-hidden="true"></span>
              <span class="visually-hidden">Next</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
