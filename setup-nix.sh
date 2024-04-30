#!/bin/sh
set -e

test ! -z $USERNAME

apk add xz
install -d -m755 -o $(id -u $USERNAME) -g $(id -g $USERNAME) /nix
wget -qO- https://nixos.org/nix/install | doas -u $USERNAME sh
