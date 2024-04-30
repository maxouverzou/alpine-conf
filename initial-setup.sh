setup-keymap us us
setup-hostname localhost
setup-interfaces -a -r
setup-timezone America/Los_Angeles
setup-apkrepos -c1
passwd -d root
setup-sshd openssh
setup-ntp busybox

echo "Enter block device name: "
read device
USERNAME=${USERNAME:-maxou} ./setup-btrfs.sh $device

echo "Reboot when ready"