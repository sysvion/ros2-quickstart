#!/usr/bin/env bash
set -e

# Install realsense SDK 2.0 from the hardware vendor hosted apt remote as of descripted in https://github.com/realsenseai/librealsense/blob/master/doc/distribution_linux.md

# setup key
sudo -A mkdir -p /etc/apt/keyrings
curl -sSf https://librealsense.realsenseai.com/Debian/librealsenseai.asc | \
gpg --dearmor | sudo -A tee /etc/apt/keyrings/librealsenseai.gpg > /dev/null

# add repo
echo "deb [signed-by=/etc/apt/keyrings/librealsenseai.gpg] https://librealsense.realsenseai.com/Debian/apt-repo `lsb_release -cs` main" | \
sudo -A tee /etc/apt/sources.list.d/librealsense.list
sudo -A apt-get update

# install
sudo -A apt-get -y install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg

git clone --depth 1 --branch ros2-master \
    https://github.com/realsenseai/realsense-ros.git \
    ~/ros_vendor_ws/src/realsense-ros

cd ~/ros_vendor_ws/
. /opt/ros/jazzy/setup.bash

# refresh sudo login timeout
sudo -A ls
rosdep install -r --from-paths src --ignore-src --rosdistro jazzy -y
colcon build --paths src/realsense-ros/* 
cd -
