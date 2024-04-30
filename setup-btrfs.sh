#!/bin/sh
set -e
DEVICE=$1

MOUNTPOINT=/mnt

BOOT_PART=${DEVICE}1
ROOT_PART=${DEVICE}2

apk add sfdisk btrfs-progs
modprobe btrfs

cat << EOF | sfdisk --quiet --label gpt ${DEVICE}
${BOOT_PART}: start=1M,size=100M,bootable
${ROOT_PART}: start=
EOF

mkfs.vfat -F32 ${BOOT_PART}
mkfs.btrfs ${ROOT_PART}

# initialize subvolumes

mount -t btrfs ${ROOT_PART} ${MOUNTPOINT}

# see https://www.jwillikers.com/btrfs-layout

btrfs subvolume create ${MOUNTPOINT}/@
btrfs subvolume create ${MOUNTPOINT}/@home
btrfs subvolume create ${MOUNTPOINT}/@var
btrfs subvolume create ${MOUNTPOINT}/@snapshots
btrfs subvolume create ${MOUNTPOINT}/@swap

btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/.cache
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/.local
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/.var
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/@snapshots
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/Downloads
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/Development
btrfs subvolume create ${MOUNTPOINT}/@home/$USERNAME/Development/@snapshots

umount ${MOUNTPOINT}

mount -o subvol=@ ${ROOT_PART} ${MOUNTPOINT}

mkdir -p \
 ${MOUNTPOINT}/boot \
 ${MOUNTPOINT}/home \
 ${MOUNTPOINT}/var \
 ${MOUNTPOINT}/.snapshots

mount -t vfat ${BOOT_PART} ${MOUNTPOINT}/boot

mount -o subvol=@home ${ROOT_PART} ${MOUNTPOINT}/home
mount -o subvol=@var ${ROOT_PART} ${MOUNTPOINT}/var
mount -o subvol=@snapshots ${ROOT_PART} ${MOUNTPOINT}/.snapshots

mount -o subvol=@home/$USERNAME $ROOT_PART $MOUNTPOINT/home/$USERNAME
mount -o subvol=@home/$USERNAME/.cache $ROOT_PART $MOUNTPOINT/home/$USERNAME/.cache
mount -o subvol=@home/$USERNAME/.local $ROOT_PART $MOUNTPOINT/home/$USERNAME/.local
mount -o subvol=@home/$USERNAME/.var $ROOT_PART $MOUNTPOINT/home/$USERNAME/.var
mount -o subvol=@home/$USERNAME/@snapshots $ROOT_PART $MOUNTPOINT/home/$USERNAME/@snapshots
mount -o subvol=@home/$USERNAME/Downloads $ROOT_PART $MOUNTPOINT/home/$USERNAME/Downloads
mount -o subvol=@home/$USERNAME/Development $ROOT_PART $MOUNTPOINT/home/$USERNAME/Development
mount -o subvol=@home/$USERNAME/Development/@snapshots $ROOT_PART $MOUNTPOINT/home/$USERNAME/Development/@snapshots

setup-disk $MOUNTPOINT

echo "MBR setup command: dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/gptmbr.bin of=$DEVICE"
