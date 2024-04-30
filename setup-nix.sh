#!/bin/sh
set -e
apk add xz
doas install -d -m755 -o $(id -u) -g $(id -g) /nix
wget -qO- https://nixos.org/nix/install | sh
