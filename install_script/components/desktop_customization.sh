#!/usr/bin/env bash
set -e

# https://help.gnome.org/system-admin-guide/desktop-favorite-applications.html
cat | sudo -A tee /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF

sudo -A mkdir -p /etc/dconf/db/local.d/ 

cat | sudo -A tee  /etc/dconf/db/local.d/00-favorite-apps <<EOF
[org/gnome/shell]
favorite-apps = ['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop','code.desktop']
EOF

sudo -A dconf update

#gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop','code.desktop', 'ros2-tutorial-gui.desktop']"
