#!/bin/sh
#Directory contains the target rootfs
TARGET_ROOTFS_DIR="deb/freescale-debian"

#Board hostname
filename=$TARGET_ROOTFS_DIR/etc/hostname
echo freescale > $filename

#Default name servers, google dns
filename=$TARGET_ROOTFS_DIR/etc/resolv.conf
echo nameserver 8.8.8.8 > $filename
echo nameserver 8.8.4.4 >> $filename

#Default network interfaces
filename=$TARGET_ROOTFS_DIR/etc/network/interfaces
echo auto lo > $filename
echo iface lo inet loopback >> $filename
#echo pre-up modprobe g_ether >> $filename
echo manual usb0 >> $filename
echo iface usb0 inet static >> $filename
echo address 192.168.10.10 >> $filename
echo netmask 255.255.255.0 >> $filename
echo gateway 192.168.10.20 >> $filename

echo auto eth0 >> $filename
echo iface eth0 inet static >> $filename
echo address 192.168.0.101 >> $filename
echo netmask 255.255.255.0 >> $filename
echo gateway 192.168.0.1 >> $filename

#Set the the debug port
filename=$TARGET_ROOTFS_DIR/etc/inittab
echo T0:2345:respawn:/sbin/getty -L ttyS0 115200 vt100 >> $filename

# #Set rules to change wlan dongles
# filename=$TARGET_ROOTFS_DIR/etc/udev/rules.d/70-persistent-net.rules
# echo SUBSYSTEM=='"net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="*", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="wlan*", NAME="wlan0"' > $filename

#microSD partitions mounting
filename=$TARGET_ROOTFS_DIR/etc/fstab
echo /dev/mmcblk0p1 /boot vfat noatime 0 1 > $filename
echo /dev/mmcblk0p2 / ext4 noatime 0 1 >> $filename
echo proc /proc proc defaults 0 0 >> $filename

#Add the standard Debian non-free repositories useful to load
#closed source firmware (i.e. WiFi dongle firmware)
#filename=$TARGET_ROOTFS_DIR/etc/apt/sources.list
#echo deb http://http.debian.net/debian/ jessie main contrib non-free > $filename

