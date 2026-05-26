# Script for installing ros2 jazzy on top of an ubuntu iso. The script is designed to run on a ubuntu chroot enviroment like what is given using cubic and install 

###########################################
# setup apt reposetories and try and make #
###########################################
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository universe --yes
sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb 
rm /tmp/ros2-apt-source.deb
sudo apt update
sudo apt install -y ros-dev-tools ros-jazzy-desktop 

# bootstrap rosdep
rosdep init && \
  rosdep update --rosdistro $ROS_DISTRO
