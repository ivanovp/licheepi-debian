#!/bin/bash

sudo umount licheepi-image/boot
sudo sudo losetup -d /dev/loop100
sudo umount licheepi-image/rootfs
sudo sudo losetup -d /dev/loop101
sudo rm licheepi-debian.img

mkdir -p licheepi-image/boot
mkdir -p licheepi-image/rootfs

dd if=/dev/zero of=licheepi-debian.img bs=1M seek=1938 count=0

cat << EOT | fdisk licheepi-debian.img
o
n
p
1
8192
+20M
n
p
2
49152
+512M
n
p
3
1097728

t
1
c
t
2
82
w
EOT

# Mount first partition

losetup -o $((512*8192)) --sizelimit 20M --nooverlap --sector-size 512 /dev/loop100 licheepi-debian.img
mkfs.vfat -n lichboot /dev/loop100
mount -t vfat /dev/loop100 licheepi-image/boot

# Mount second partition

losetup -o $((512*1097728)) --sizelimit $((512*2867200)) --nooverlap --sector-size 512 /dev/loop101 licheepi-debian.img
mkfs.ext4 /dev/loop101 -L licheepi_root
mount -t ext4 /dev/loop101 licheepi-image/rootfs

# Make swap
#TODO
