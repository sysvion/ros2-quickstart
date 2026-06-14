# script for installing ros2 jazzy on top of an ubuntu iso. the script is designed to run on a ubuntu chroot enviroment like what is given using cubic and install 

###########################################
# setup apt reposetories and try and make #
###########################################
echo '==> setup reposetories' >> /tmp/install.log
sudo -A apt update
sudo -A apt install software-properties-common -y
sudo -A add-apt-repository universe --yes
echo '==> curl' >> /tmp/install.log
sudo -A apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo -A dpkg -i /tmp/ros2-apt-source.deb
rm /tmp/ros2-apt-source.deb
echo '==> install ros' >> /tmp/install.log
sudo -A apt update
sudo -A apt install -y ros-dev-tools ros-jazzy-desktop 

echo '==> rosdep'
# bootstrap rosdep
sudo -A rosdep init && \
  rosdep update --rosdistro jazzy
