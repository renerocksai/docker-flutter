# docker-flutter

This is work in progress. The rest of this README does not fully apply.

So far, I have updated stable/Dockerfile etc. to create a `flutter-stable` docker container including nvim and
flutter-tools for nvim.

Build the container via `./build_flutter-stable.sh`.

Or `docker pull ghcr.io/renerocksai/flutter-nvim-stable`.

Unfortunately, most recent 2.10 releases of flutter fail to install due to some bug that thinks the flutter command is
being executed within a flutter project and complains about some Android XML stuff.

So, as a workaround, I install flutter 2.2.1 and perform a `flutter upgrade` afterwards. This works like a charm 😊!

---

# WIP

With this docker image you don't need to install the Flutter and Android SDK on your developer machine. Everything is
ready to use inclusive an emulator device (Pixel with Android 9). With a shell alias you won't recognize a difference
between the image and a local installation. If you are using VSCode you can also use this image as your devcontainer.

## Github Container Registry

A GitHub action is in place that builds and pushes the `stable` container to ghcr.

## Start the container

See `./start-docker.sh`. It's a Linux example startup script to run your container with starting an emulator in mind.

From within the container, I recommend starting a `tmux` session, so you can split nvim and a shell.

Also, please run `flutter pub get` in your app directory every time you (re-) start the container - as flutter's cache
dirs will be reset. Might be improved in the future

Run `flutter-android-emulator.sh` to start an emulator (on Linux).  After that, just `flutter run` from your flutter
project directory.

## flutter (connected usb device)

Connecting to a device connected via usb is possible via:

```shell
docker run --rm -e UID=$(id -u) -e GID=$(id -g) \
       --workdir /project \
       -v "$PWD":/project \
       --device=/dev/bus \
       -v /dev/bus/usb:/dev/bus/usb \
       flutter-stable
```

## flutter-android-emulator

To achieve the best performance we will mount the X11 directory, DRI and KVM device of the host to get full hardware acceleration:

```shell
xhost local:$USER && docker run --rm -ti -e UID=$(id -u) \
      -e GID=$(id -g) -p 42000:42000 --workdir /project \
      --device /dev/kvm \
      --device /dev/dri:/dev/dri \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -e DISPLAY \
      -v "$PWD":/project \
      --entrypoint flutter-android-emulator \
      flutter-stable
```

## flutter-web

You app will be served on localhost:8090:

```shell
docker run --rm -ti -e UID=$(id -u) -e GID=$(id -g) \
       -p 42000:42000 \
       -p 8090:8090  \
       --workdir /project \
       -v "$PWD":/project \
       --entrypoint flutter-web \
       flutter-stable
```

## VSCode devcontainer

You can also use this image to develop inside a devcontainer in VSCode and launch the android emulator or web-server.
The android emulator need hardware acceleration, so their is no best practice for all common operating systems.

### Linux #1 (X11 & KVM forwarding)

For developers using Linux as their OS I recommend this approach, because it's the overall cleanest way.

Add this `.devcontainer/devcontainer.json` to your VSCode project:

```json
{
  "name": "Flutter",
  "image": "flutter-stable",
  "extensions": ["dart-code.dart-code", "dart-code.flutter"],
  "runArgs": [
    "--device",
    "/dev/kvm",
    "--device",
    "/dev/dri:/dev/dri",
    "-v",
    "/tmp/.X11-unix:/tmp/.X11-unix",
    "-e",
    "DISPLAY"
  ]
}
```

When VSCode has launched your container you have to execute `flutter emulators --launch flutter_emulator` to startup the
emulator device. Afterwards you can choose it to debug your flutter code.

### Linux #2, Windows & MacOS (using host emulator)

Add this `.devcontainer/devcontainer.json` to your VSCode project:

```json
{
  "name": "Flutter",
  "image": "flutter-stable",
  "extensions": ["dart-code.dart-code", "dart-code.flutter"]
}
```

Start your local android emulator. Afterwards reconnect execute the following command to make it accessable via network:

```shell
adb tcpip 5555
```

In your docker container connect to device:

```shell
adb connect host.docker.internal:5555
```

You can now choose the device to start debugging.
