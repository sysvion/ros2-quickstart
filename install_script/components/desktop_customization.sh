#!/usr/bin/env bash
set -e


# https://help.gnome.org/system-admin-guide/desktop-favorite-applications.html
sudo -A tee /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF

sudo -A mkdir -p /etc/dconf/db/local.d/ 

sudo -A tee  /etc/dconf/db/local.d/00-favorite-apps <<EOF
[org/gnome/shell]
favorite-apps = ['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'account-creation-tool.desktop', 'org.gnome.Nautilus.desktop','code.desktop', 'ros2-tutorial-gui.desktop', 'start_ursim.desktop', 'ur_moveit.desktop']

[org/gnome/desktop/background]

# Specify the path to the desktop background image file
picture-uri='file:///opt/install/components/art002e009285~large.jpg'

# Specify one of the rendering options for the background image:
picture-options='zoom'

# Specify the left or top color when drawing gradients, or the solid color
primary-color='000000'

# Specify the right or bottom color when drawing gradients
secondary-color='FFFFFF'
EOF

sudo -A dconf update

#gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop','code.desktop', 'ros2-tutorial-gui.desktop']"
