set -xe

create_subvolumes() {
	local prefix=$1
    local volume_prefix=@${prefix:1}

    shift

    for volume in $@
    do
        btrfs subvolume create $volume_prefix$volume
    done
}

mount_subvolumes() {
    local partition=$1
	local prefix=$2
    local volume_prefix=@${prefix:1}

    shift
    shift

    for volume in $@
    do
        mkdir -p $prefix$volume
        mount -o subvol=$volume_prefix$volume $partition $prefix$volume
    done
}

# ROOTFS=btrfs VARFS=btrfs setup-disk -L -m sys /dev/vda
DEVICE=$1

MOUNTPOINT=/mnt

BOOT_PART=${DEVICE}1
ROOT_PART=${DEVICE}2

apk add sfdisk btrfs-progs
modprobe btrfs

# TODO: use GPT
cat << EOF | sfdisk --quiet --label dos ${DEVICE}
${BOOT_PART}: start=1M,size=100M,bootable
${ROOT_PART}: start=
EOF

mkfs.vfat -F32 ${BOOT_PART}
mkfs.btrfs ${ROOT_PART}

# initialize subvolumes
# see https://www.jwillikers.com/btrfs-layout

mount -t btrfs ${ROOT_PART} ${MOUNTPOINT}

base_volumes="/ /home /.snapshots /.swap /var"
create_subvolumes $MOUNTPOINT $base_volumes

xdg_volumes="/ /.cache /.local /.var /.snapshots /Downloads /Development /Development/.snapshots"
create_subvolumes ${MOUNTPOINT}/home/maxou $xdg_volumes

umount ${MOUNTPOINT}

# mount subvolumes

mount -o subvol=@ ${ROOT_PART} ${MOUNTPOINT}

mount_subvolumes $ROOT_PART $MOUNTPOINT $base_volumes
mount_subvolumes $ROOT_PART $MOUNTPOINT/home/maxou $xdg_volumes

# mkdir -p \
#  ${MOUNTPOINT}/.snapshots \
#  ${MOUNTPOINT}/.swap
#  ${MOUNTPOINT}/boot \
#  ${MOUNTPOINT}/home \
#  ${MOUNTPOINT}/var \
# 
# mount -o subvol=@snapshots ${ROOT_PART} ${MOUNTPOINT}/.snapshots
# mount -o subvol=@swap ${ROOT_PART} ${MOUNTPOINT}/.swap
# mount -o subvol=@var ${ROOT_PART} ${MOUNTPOINT}/var
mount -t vfat ${BOOT_PART} ${MOUNTPOINT}/boot

# mount -o subvol=@home ${ROOT_PART} ${MOUNTPOINT}/home
# mount_xdg_subvolumes $ROOT_PART $MOUNTPOINT/home/maxou

#   cat << EOF > ${MOUNTPOINT}/fstab
#   $(blkid ${ROOT_PART} | awk '{print $2}')   /       btrfs   subvol=@,ro,noatime 0 0
#   $(blkid ${ROOT_PART} | awk '{print $2}')   /var    btrfs   subvol=@var,rw,noatime 0 0
#   $(blkid ${ROOT_PART} | awk '{print $2}')   /home   btrfs   subvol=@var,rw,noatime 0 0
#   $(blkid ${BOOT_PART} | awk '{print $2}')   /boot   vfat    rw,noatime,discard 0 2
#   tmpfs /tmp tmpfs mode=1777,noatime,nosuid,nodev,size=2G 0 0
#   $(blkid ${SWAP_PART} | awk '{print $2}')   swap    swap    rw,noatime,discard 0 0
#   EOF

setup-disk ${MOUNTPOINT}

#   apk -X https://dl-cdn.alpinelinux.org/alpine/latest-stable/main \
#       -U --allow-untrusted \
#       -p ${MOUNTPOINT} \
#       --initdb add alpine-base
#   
#   mount -o bind /dev ${MOUNTPOINT}/dev
#   mount -t proc none ${MOUNTPOINT}/proc
#   mount -t sysfs sys ${MOUNTPOINT}/sys
#   
#   cp -L /etc/resolv.conf "${MOUNTPOINT}/etc/"
#   chroot "${MOUNTPOINT}" /bin/sh
#   
#   cat << 'EOF' | chroot ${MOUNTPOINT} /bin/sh
#       mount -a
#       mv /etc/resolv.conf /tmp/
#       ln -s /tmp/resolv.conf /etc/resolv.conf
#   
#       setup-apkrepos -c1
#       setup-devd udev
#   
#       apk add -U \
#           linux-firmware linux-lts btrfs-progs \
#           openresolv \
#           networkmanager networkmanager-wifi networkmanager-tui
#   
#       initfs_features=$(cat /etc/mkinitfs/mkinitfs.conf | awk -F '"' '{ print $2 }')
#       echo "features=\"${initfs_features} btrfs\"" > /etc/mkinitfs/mkinitfs.conf
#       mkinitfs
#   
#   EOF