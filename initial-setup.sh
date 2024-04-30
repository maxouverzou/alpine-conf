#!/bin/sh
set -e
setup-keymap us us
setup-hostname localhost
setup-interfaces -a -r
setup-timezone America/Los_Angeles
setup-apkrepos -c1
passwd -d root
setup-sshd openssh
setup-ntp busybox

sh ./setup-btrfs.sh $DEVICE

echo "Reboot when ready"