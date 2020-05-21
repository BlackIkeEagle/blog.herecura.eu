#!/usr/bin/env bash

[[ -e arch-rootfs.ext4 ]] && rm arch-rootfs.ext4

truncate -s 2G arch-rootfs.ext4
sudo mkfs.ext4 arch-rootfs.ext4

sudo mkdir -p /mnt/arch-root
sudo mount "$(pwd)"/arch-rootfs.ext4 /mnt/arch-root
sudo pacstrap /mnt/arch-root base

echo "firecracker-arch" | sudo tee -a /mnt/arch-root/etc/hostname
sudo rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
sudo rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*
ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target
sudo arch-chroot /mnt/arch-root passwd -d root

sudo umount /mnt/arch-root
sudo rmdir /mnt/arch-root
