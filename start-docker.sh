#!/usr/bin/env bash
xhost local:$USER && docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) -p 42000:42000 --workdir /project --device
/dev/kvm --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -v "$PWD":/project --entrypoint
./inside.sh  ghcr.io/renerocksai/flutter-nvim-stable


# for connected usb devices:
# play with this:
# docker run --rm -e UID=$(id -u) -e GID=$(id -g) --workdir /project -v "$PWD":/project --device=/dev/bus -v
# /dev/bus/usb:/dev/bus/usb ghcr.io/renerocksai/flutter-nvim-stable devices
