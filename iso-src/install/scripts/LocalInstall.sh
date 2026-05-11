set -e

bash ../components/build_and_install_doosan_driver.sh
sudo bash ../components/install_apt_dependencies.sh
sudo bash ../components/install_ros2.sh
sudo bash ../components/install_vs_code.sh
