#!/bin/sh
set -e
test ! -z $DEVICE
test ! -z $USERNAME
setup-keymap us us
setup-hostname localhost
setup-interfaces -a -r
setup-timezone America/Los_Angeles
setup-apkrepos -c1
passwd -d root
setup-sshd openssh
setup-ntp busybox

sh ./setup-btrfs.sh

echo "Reboot when ready"