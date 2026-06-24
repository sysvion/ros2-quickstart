#!/usr/bin/env bash
set -e

cat | sudo -A tee /usr/share/applications/doosan_moveit.desktop <<EOF
[Desktop Entry]
Name=moveit
Type=Application
Exec=bash -c 'source /opt/ros/jazzy/setup.bash && source \$HOME/ros_vendor_ws/doosan/install/setup.bash && ros2 launch dsr_bringup2 dsr_bringup2_moveit.launch.py mode:=virtual model:=m1013 host:=127.0.0.1'
Terminal=true
Icon=/opt/install/components/rviz.png
EOF

# https://help.gnome.org/system-admin-guide/desktop-favorite-applications.html
cat | sudo -A tee /etc/dconf/profile/user <<EOF
user-db:user
system-db:local
EOF

sudo -A mkdir -p /etc/dconf/db/local.d/ 

cat | sudo -A tee  /etc/dconf/db/local.d/00-favorite-apps <<EOF
[org/gnome/shell]
favorite-apps = ['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop','code.desktop', 'ros2-tutorial-gui.desktop', 'doosan_moveit.desktop']
EOF

sudo -A dconf update

#gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop','code.desktop', 'ros2-tutorial-gui.desktop']"
