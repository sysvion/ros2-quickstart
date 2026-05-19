FROM ros:jazzy-ros-base-noble
# INFO: use `just docker-build` to create this! normal docker build does not work because of how i handled file references

RUN --mount=type=bind,target=/install_apt_dependencies.sh,source=./components/install_apt_dependencies.sh \
    bash /install_apt_dependencies.sh

RUN --mount=type=bind,target=/build_and_install_doosan_driver.sh,source=./components/build_and_install_doosan_driver.sh \
    bash /build_and_install_doosan_driver.sh

RUN --mount=type=bind,target=/install_vs_code.sh,source=./components/install_vs_code.sh  \
    bash /install_vs_code.sh

RUN --mount=type=bind,target=/realsense_apt_installation.sh,source=./components/realsense_apt_installation.sh \
    bash /realsense_apt_installation.sh

RUN --mount=type=bind,target=/practicum_dependencies.sh,source=./components/practicum_dependencies.sh \
    bash /practicum_dependencies.sh

# i wanna spawn multiple terminals
RUN apt install -y kitty
