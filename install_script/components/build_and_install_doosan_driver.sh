
# install instructions copied from https://github.com/DoosanRobotics/doosan-robot2/tree/jazzy

sudo -A apt-get install -y \
    libpoco-dev libyaml-cpp-dev wget \
  ros-jazzy-control-msgs ros-jazzy-realtime-tools ros-jazzy-xacro \
  ros-jazzy-joint-state-publisher-gui ros-jazzy-ros2-control \
  ros-jazzy-ros2-controllers ros-jazzy-gazebo-msgs ros-jazzy-moveit-msgs \
  dbus-x11 ros-jazzy-moveit-configs-utils ros-jazzy-moveit-ros-move-group

source /opt/ros/jazzy/setup.bash
git clone --depth 1 --branch jazzy https://github.com/DoosanRobotics/doosan-robot2 ~/ros_vendor_ws/src/doosan
cd ~
rosdep install -r --from-paths src --ignore-src --rosdistro jazzy -y
colcon build
cd -
