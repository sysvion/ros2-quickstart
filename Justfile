docker-build:
    docker build \
        --file iso-src/install/scripts/Dockerfile \
        --tag ros-prac \
        .

docker-x11-session:
    docker run \
        --rm \
        -it \
        --network host \
        -e DISPLAY=$DISPLAY \
        --volume /tmp/.X11-unix/:/tmp/.X11-unix/ \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        ros-prac
