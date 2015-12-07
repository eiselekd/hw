#!/bin/sh
#echo "[*] Mounting Rootfs..."
#mount -o loop,noatime -t ext3 /data_debian/squeeze.ext3 /mnt/debian
echo "[*] Preparing Filesystem..."
mount -o bind /dev /mnt/debian/dev
mount -o bind /proc /mnt/debian/proc
mount -o bind /sys /mnt/debian/sys
echo "[*] Preparing Network Connections..."
cp /etc/passwd /mnt/debian/etc/passwd
cp /etc/shadow /mnt/debian/etc/shadow
cp /etc/sudoers /mnt/debian/etc/sudoers
cp /etc/hosts /mnt/debian/etc/hosts
cp /etc/resolv.conf /mnt/debian/etc/resolv.conf
echo "debian" > /mnt/debian/etc/hostname
echo "[*] Starting Shell..."
export SHELL=/bin/bash
chroot /mnt/debian /bin/bash
echo "[*]Unmounting Rootfs..."
umount /mnt/debian/dev
umount /mnt/debian/proc
umount /mnt/debian/sys
umount /mnt/debian
