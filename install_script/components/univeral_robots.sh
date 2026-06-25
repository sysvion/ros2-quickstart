echo "===> install universal robots" >> /tmp/install.log
sudo -A apt install ros-jazzy-ur -y

sudo tee /usr/share/applications/start_ursim.desktop <<EOF 
[Desktop Entry]
Name=Start latest Ursim for ur5e
Type=Application
Exec=bash -c 'source /opt/ros/jazzy/setup.bash && ros2 run ur_client_library start_ursim.sh -m ur5e -i 192.168.56.\${ROS_DOMAIN_ID:-2} -n "ursimFor\$USER"'
Terminal=true
Icon=/opt/install/components/ur.png
EOF

sudo tee /usr/share/applications/ur_moveit.desktop <<EOF
[Desktop Entry]
Name=ur moveit
Type=Application
Exec=bash -c 'source /opt/ros/jazzy/setup.bash && ros2 launch ur_robot_driver ur_control.launch.py ur_type:=ur5e robot_ip:=192.168.56.\${ROS_DOMAIN_ID:-2} launch_rviz:=false &  sleep 5 && source /opt/ros/jazzy/setup.bash && ros2 launch ur_moveit_config ur_moveit.launch.py ur_type:=ur5e launch_rviz:=true'
Terminal=true
Icon=/opt/install/components/rviz.png
EOF
