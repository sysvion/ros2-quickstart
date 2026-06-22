set -e

touch /tmp/install.log
sudo -A chmod o=rw /tmp/install.log

bash components/install_ros2.sh

bash components/docker.sh

bash components/univeral_robots.sh
bash components/build_and_install_doosan_driver.sh

bash components/install_vs_code.sh

bash components/realsense_apt_installation.sh

sudo -A bash components/practicum_dependencies.sh
bash components/tutorial_gui.sh

bash components/desktop_customization.sh
