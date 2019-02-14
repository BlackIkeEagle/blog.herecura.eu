---
title: "Arch Linux reinstall script"
description: "Arch Linux reinstall script"
date: "2019-02-14"
categories:
  - "Arch Linux"
  - "linux"
  - "installer"
tags:
  - "linux"
---

To suit my personal preferences and diverting package choices compared to stock
arch linux I have created a simple reinstall script to suit my needs.

## goal

The goal is to have a somewhat uniform way of installing my machines and have
full disk encryption for root. Here the unlock key is stored on a portable usb
device for additional security. You can argue about the added value over a
password, but I like it this way.

The script should also enable me to install a new machine fairly quickly
without having to do all the things manually. So if I want to use Deepin
desktop, Plasma desktop, i3 or fluxbox, I want to get a working set of packages
which I can start working with. Eventually there might be packages I need to do
something extra, but I just tried to have a sane default for myself.

<!--more-->

## choices

I made some choices for myself how I want to install my machines.

- filesystem: xfs or btrfs
- bootloader: grub
- default user: ike
- keyboard layout: belgian

My preferred filesystems are xfs and btrfs. For a default install I will
probably use xfs, but if I want to have snapshots and other customizability I
will pick btrfs. Before I was using syslinux or refind as bootloader, but
because this added additional complexity I switched back to grub, this allows
for installs on msdos (bios) or gpt (EFI) the same way.

## How to use

### Prepare

- download [the iso](https://www.archlinux.org/download/) somewhere
- put the iso on a usb or cd
- boot your system with the iso

### Basic live env setup

#### keyboard setup

If you need to change your keyboard layout like me, first thing to run is

```
$ loadkeys be-latin1
```

Or `loadkeys` with your keymap.

#### wifi

Configure wifi if needed

```
$ wifi-menu
```
#### prepare usb 'key' device

If you have an empty device you also have to format it.

```
$ mkfs.ext2 -L keydrive /dev/sdb1
```

Make the `/media/usb` directory.

```
$ mkdir -p /media/usb
```

And then mount the usb 'key' device to `/media/usb`

```
$ mount /dev/sdb1 /media/usb
```

## Installation

### Check some things

- what will be my root disk (sda, nvme1)
- will I do EFI boot or BIOS boot

### get the archlinux-reinstall repo

We need git to get the archlinux-reinstall repo

```
$ pacman -Sy git
```

clone the repo

```
$ git clone https://github.com/BlackIkeEagle/archlinux-reinstall.git
```

Go into the new folder and run 'a' installer (see [installer
types](#installer-types))

```
$ cd archlinux-reinstall
$ ./install.sh
```

The script will ask 6 questions and then run almost until you can reboot.

- Which blockdevice (pass it without leading /dev/)
- efi or legacy boot
- btrfs or xfs
- nvme disk? (nvme disks add a 'p' for the partitions)
- checkblocks (do you first want to run checkblocks on the device)
- root password (at the end of the run)

If you run as described above you will get a minimal install of archlinux with
my preferred kernel and configuration.

### reboot and post install

Reboot and remove the installation medium.

when logged in as root, first run `./post-install-first-run.sh`. And then
continue configuring whatever you want. The inital password for the ike user is
set expired so you have to pick a new password on first login. Also this first
login should better be done before trying to login with a display manager.

## installer types

### install.sh

This is just a minimal working system with xfs or btrfs.

### install-plasma.sh

Install Plasma desktop with the required packages to have a nice working Plasma
environment.

### install-deepin.sh

Install Deepin desktop the way I think it works properly without installing
everything of the deepin group.

### install-i3.sh

Installs i3 with some extra packages for desktopish operation. This comes
without display manager because I use it with startx.

### install-fluxbox.sh

Installs fluxbox with extra packages for desktop use.

## Closing

I made this just for me, if you find it usefull feel free to use it. You might
need to to some customizations to suit your needs.
