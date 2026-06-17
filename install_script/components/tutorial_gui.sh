#!/usr/bin/env bash

git clone https://github.com/sysvion/qt-tutorial-app.git $HOME/.local/share/ros2-tutorial-gui/src
cd $HOME/.local/share/ros2-tutorial-gui/src

# setup venv
sudo -A apt install pytho3-venv python3-pip
python3 -m venv venv
source ./venv/bin/activate
pip install -r requirements.txt

cd ..
colcon build --symlink-install

mv src/app.desktop $HOME/.local/share/applications/ros2-tutorial-gui.desktop
