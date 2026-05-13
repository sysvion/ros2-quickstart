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

# TODO: clone && rosdep update && colcon build reaksenseai's ros wrapper
# https://github.com/realsenseai/realsense-ros
