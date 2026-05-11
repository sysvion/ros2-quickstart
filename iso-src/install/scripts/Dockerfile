FROM ros:jazzy-ros-base-noble

RUN --mount=type=bind,target=/install_apt_dependencies.sh,source=../install_apt_dependencies.sh \
    bash /install_apt_dependencies.sh

RUN --mount=type=bind,target=/build_doosan.sh ,source=../build_and_install_doosan_driver.sh \
    bash /build_doosan.sh

RUN --mount=type=bind,target=/install_vs_code.sh,source=../install_vs_code.sh \
    bash /install_vs_code.sh
