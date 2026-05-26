set -e
git clone --depth 1 https://github.com/Slamtec/sllidar_ros2 /opt/ros_vendor_ws/src/sllidar_ros2
cd /opt/ros_vendor_ws
. /opt/ros/jazzy/setup.bash
colcon build
cd -
