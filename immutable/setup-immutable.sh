#!/bin/sh

# format & mount to /mnt


mkdir /mnt/next # next current link, is necessary due to how busybox mv does atomic link replacement
mkdir /mnt/commons # common non-snapshotting subvolumes
mkdir /mnt/snapshots  # directories containing snapshots belonging to one generation.
mkdir /mnt/links # generations of directories containing links to snapshot generations.

btrfs subvolume create /mnt/commons/@var
btrfs subvolume create /mnt/commons/@home

# create first generation

NEWSNAPSHOTS="$(date -u +"%Y%m%d%H%M%S")$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)"
mkdir "/mnt/snapshots/$NEWSNAPSHOTS"
btrfs subvolume create /mnt/snapshots/$NEWSNAPSHOTS/@


NEWLINKS="$(date -u +"%Y%m%d%H%M%S")$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 8 | head -n 1)"
mkdir "/mnt/links/$NEWLINKS"
ln -s "../../snapshots/$NEWSNAPSHOTS" "/mnt/links/$NEWLINKS/0"
ln -s "../../snapshots/$NEWSNAPSHOTS" "/mnt/links/$NEWLINKS/1"
ln -s "../../snapshots/$NEWSNAPSHOTS" "/mnt/links/$NEWLINKS/2"
ln -s "../../snapshots/$NEWSNAPSHOTS" "/mnt/links/$NEWLINKS/3"

ln -s "./links/$NEWLINKS" /mnt/current

blkid > /mnt/fstab
# edit /mnt/fstab

# base system install
apk -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted -p /mnt/snapshots/$NEWSNAPSHOTS/@ --initdb add alpine-base

# Now we can setup basic chroot to complete the installation process: 
export SNP="/mnt/snapshots/$NEWSNAPSHOTS/@"
mount -o bind /dev $SNP/dev
mount -t proc none $SNP/proc
mount -t sysfs sys $SNP/sys
sed "s#CURRENT_SNAPSHOTS_PATH#/snapshots/$NEWSNAPSHOTS#g" /mnt/fstab > "$SNP/etc/fstab"
cp -L /etc/resolv.conf "$SNP/etc/"
chroot "$SNP" /bin/sh
mount -a
mv /etc/resolv.conf /tmp/
ln -s /tmp/resolv.conf /etc/resolv.conf

