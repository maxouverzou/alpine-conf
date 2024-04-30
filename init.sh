# enable community repo
sed -i 's/#\(.*\/community\)/\1/' /etc/apk/repositories

# install kde
apk add dbus
rc-update add dbus
rc-service dbus start # to avoid restart

apk add elogind
rc-update add elogind
rc-service elogind start

apk add polkit-elogind
rc-update add polkit
rc-service polkit start

# https://wiki.alpinelinux.org/wiki/NetworkManager#iwd_backend

# PAM?

apk add xf86-input-libinput


apk add sudo xz curl doas

NEWUSER='yourUserName'
adduser -g "${NEWUSER}" $NEWUSER
echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers.d/$NEWUSER && chmod 0440 /etc/sudoers.d/$NEWUSER

apk add xz curl
$ sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
$ curl -L https://nixos.org/nix/install | sh

$ source $HOME/.nix-profile/etc/profile.d/nix.sh

apk add flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.valvesoftware.Steam
flatpak install flathub org.mozilla.firefox
flatpak install flathub org.qgis.qgis

flatpak install https://downloads.1password.com/linux/flatpak/1Password.flatpakref
flatpak run com.onepassword.OnePassword
