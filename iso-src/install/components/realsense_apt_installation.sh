#!/usr/bin/env bash

set -e

# Install realsense SDK 2.0 from the hardware vendor hosted apt remote as of descripted in https://github.com/realsenseai/librealsense/blob/master/doc/distribution_linux.md

# setup key
sudo mkdir -p /etc/apt/keyrings
curl -sSf https://librealsense.realsenseai.com/Debian/librealsenseai.asc | \
gpg --dearmor | sudo tee /etc/apt/keyrings/librealsenseai.gpg > /dev/null

# add repo
echo "deb [signed-by=/etc/apt/keyrings/librealsenseai.gpg] https://librealsense.realsenseai.com/Debian/apt-repo `lsb_release -cs` main" | \
sudo tee /etc/apt/sources.list.d/librealsense.list
sudo apt-get update

# install
sudo apt-get -y install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg

git clone --depth 1 --branch ros2-master \
    https://github.com/realsenseai/realsense-ros.git \
    /opt/ros_vendor_ws/src/realsense-ros

find /opt/ros_vendor_ws/src/realsense-ros/ -name "*.cpp" -exec sed --in-place "s/cv_bridge.h>/cv_bridge.hpp>/g" {} \+

cd /opt/ros_vendor_ws/
. /opt/ros/jazzy/setup.bash
rosdep install -r --from-paths src --ignore-src --rosdistro jazzy -y
colcon build --paths src/realsense-ros/* --cmake-args -DRVIZ_RGBD_PLUGIN=ON
cd -
