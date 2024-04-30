#!/bin/sh
set -e

test ! -z $DEVICE
test ! -z $USERNAME

mountpoint=/mnt

boot_part=${DEVICE}1
root_part=${DEVICE}2

apk add sfdisk btrfs-progs
modprobe btrfs

cat << eof | sfdisk --quiet --label gpt $DEVICE
$boot_part: start=1m,size=100m,bootable
$root_part: start=
eof

mkfs.vfat -f32 ${boot_part}
mkfs.btrfs ${root_part}

# initialize subvolumes

mount -t btrfs ${root_part} ${mountpoint}

# see https://www.jwillikers.com/btrfs-layout

btrfs subvolume create $mountpoint/@
btrfs subvolume create $mountpoint/@home
btrfs subvolume create $mountpoint/@var
btrfs subvolume create $mountpoint/@snapshots
btrfs subvolume create $mountpoint/@swap

btrfs subvolume create $mountpoint/@home/$USERNAME
btrfs subvolume create $mountpoint/@home/$USERNAME/.cache
btrfs subvolume create $mountpoint/@home/$USERNAME/.local
btrfs subvolume create $mountpoint/@home/$USERNAME/.var
btrfs subvolume create $mountpoint/@home/$USERNAME/@snapshots
btrfs subvolume create $mountpoint/@home/$USERNAME/downloads
btrfs subvolume create $mountpoint/@home/$USERNAME/development
btrfs subvolume create $mountpoint/@home/$USERNAME/development/@snapshots

umount $mountpoint

mount -o subvol=@ $root_part $mountpoint

mkdir -p \
 $mountpoint/boot \
 $mountpoint/home \
 $mountpoint/var \
 $mountpoint/.snapshots

mount -t vfat $boot_part $mountpoint/boot

mount -o subvol=@home $root_part $mountpoint/home
mount -o subvol=@var $root_part $mountpoint/var
mount -o subvol=@snapshots $root_part $mountpoint/.snapshots

mount -o subvol=@home/$USERNAME $root_part $mountpoint/home/$USERNAME
mount -o subvol=@home/$USERNAME/.cache $root_part $mountpoint/home/$USERNAME/.cache
mount -o subvol=@home/$USERNAME/.local $root_part $mountpoint/home/$USERNAME/.local
mount -o subvol=@home/$USERNAME/.var $root_part $mountpoint/home/$USERNAME/.var
mount -o subvol=@home/$USERNAME/@snapshots $root_part $mountpoint/home/$USERNAME/@snapshots
mount -o subvol=@home/$USERNAME/downloads $root_part $mountpoint/home/$USERNAME/downloads
mount -o subvol=@home/$USERNAME/development $root_part $mountpoint/home/$USERNAME/development
mount -o subvol=@home/$USERNAME/development/@snapshots $root_part $mountpoint/home/$USERNAME/development/@snapshots

BOOTLOADER=grub setup-disk -v $mountpoint

echo "MBR setup command: dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/gptmbr.bin of=$DEVICE"
