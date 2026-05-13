FROM ros:jazzy-ros-base-noble

COPY iso-src/install/components/ /components/

RUN  bash /components/install_apt_dependencies.sh

RUN  bash /components/build_and_install_doosan_driver.sh

RUN  bash /components/install_vs_code.sh

RUN bash /components/realsense_apt_installation.sh

RUN bash /components/practicum_dependencies.sh


# i wanna spawn multiple terminals
RUN apt install -y kitty
