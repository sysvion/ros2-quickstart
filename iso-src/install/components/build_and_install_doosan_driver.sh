source /opt/ros/jazzy/setup.bash
git clone --depth 1 --branch jazzy https://github.com/DoosanRobotics/doosan-robot2 /opt/ros_vendor_ws/src/doosan
cd /opt/ros_vendor_ws/
rosdep install -r --from-paths src --ignore-src --rosdistro jazzy -y
colcon build
