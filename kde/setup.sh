USERNAME=maxou

setup-keymap us us
setup-hostname localhost
setup-interfaces -a -r
setup-timezone America/Los_Angeles
setup-apkrepos -c1

passwd

setup-sshd openssh
setup-ntp chrony

# setup-disk
ROOTFS=btrfs VARFS=btrfs setup-disk -L -m sys /dev/vda

# reboot!

# setup user
setup-user -a $USERNAME

# setup desktop
setup-devd udev
BROWSER="direnv" setup-desktop plasma

# setup nix
install -d -m755 -o $(id -u $USERNAME) -g $(id -g $USERNAME) /nix
apk add curl xz
curl -sL https://nixos.org/nix/install | doas -u $USERNAME sh
