#!/usr/bin/env bash


sudo -A git clone https://github.com/sysvion/qt-tutorial-app.git /etc/skel/.local/share/ros2-tutorial-gui/src
cd /etc/skel/.local/share/ros2-tutorial-gui/src

# setup venv
sudo -A apt install -y python3-venv python3-pip
sudo -A python3 -m venv venv
sudo -A bash -c "source ./venv/bin/activate && pip install -r requirements.txt"

cd ..
sudo -A colcon build --symlink-install

sudo -A mkdir -p /etc/skel/.local/share/applications
cat | sudo -A tee /etc/skel/.local/share/applications/ros2-tutorial-gui.desktop <<EOF
[Desktop Entry]
Name=ros2 quickstart tutorial
Type=Application
Exec=bash -c '\$HOME/.local/share/ros2-tutorial-gui/src/start_app.sh'
Terminal=true
EOF
