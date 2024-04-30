#!/bin/sh
set -e
setup-user -a $USERNAME
setup-devd udev
# BROWSER="direnv" setup-desktop plasma

sh ./setup-nix.sh