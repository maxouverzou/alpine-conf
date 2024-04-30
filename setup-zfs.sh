#!/bin/sh

# from https://wiki.alpinelinux.org/wiki/Root_on_ZFS_with_native_encryption#Partition_setup

apk add zfs sfdisk e2fsprogs syslinux grub

DEVICE=/dev/vda
MOUNTPOINT=/mnt

cat << EOF | sfdisk --quiet --label dos ${DEVICE}
${DEVICE}1: start=1M,size=100M,bootable
${DEVICE}2: start=101M
EOF

mdev -s
mkfs.ext4 ${DEVICE}1

modprobe zfs
zpool create -f -o ashift=12 \
    -O acltype=posixacl -O canmount=off -O compression=lz4 \
    -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa \
    -O mountpoint=/ -R $MOUNTPOINT \
    rpool ${DEVICE}2
zpool status

# create the required datasets and mount root
zfs create -o mountpoint=none -o canmount=off rpool/ROOT
zfs create -o mountpoint=legacy rpool/ROOT/alpine
mount -t zfs rpool/ROOT/alpine ${MOUNTPOINT}/

# mount the /boot filesystem
mkdir ${MOUNTPOINT}/boot/
mount -t ext4 ${DEVICE}1 ${MOUNTPOINT}/boot/

# enable XFS' services
rc-update add zfs-import sysinit
rc-update add zfs-mount sysinit

# install
setup-disk $MOUNTPOINT
dd if=/usr/share/syslinux/mbr.bin of=/dev/sda # write mbr so we can boot
