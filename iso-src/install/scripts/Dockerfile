FROM ros:jazzy-ros-base-noble

COPY iso-src/install/components/ /components/

RUN  bash /components/install_apt_dependencies.sh

RUN  bash /components/build_and_install_doosan_driver.sh

RUN  bash /components/install_vs_code.sh
