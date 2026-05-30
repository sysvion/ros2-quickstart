docker-build:
    DOCKER_BUILDKIT=1 docker build \
        --file iso-src/install/scripts/Dockerfile \
        --tag ros-prac \
        iso-src/install

create-vm:
    bash ./iso-src/install/scripts/create_vbox_ubuntu_vm.sh

docker-x11-minimal:
    docker run \
        --rm \
        -it \
        -e DISPLAY=$DISPLAY \
        --volume /tmp/.X11-unix/:/tmp/.X11-unix/ \
        ros-prac

docker-x11-priv:
    docker run \
        --rm \
        -it \
        --privileged \
        --network host \
        -e DISPLAY=$DISPLAY \
        --volume /dev/bus/usb/:/dev/bus/usb/ \
        --volume /tmp/.X11-unix/:/tmp/.X11-unix/ \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        ros-prac
