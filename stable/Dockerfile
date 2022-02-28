FROM ubuntu:20.04

ENV UID=1000
ENV GID=1000
ENV USER="rs"
ENV JAVA_VERSION="8"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
# ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip"
ENV ANDROID_VERSION="29"
ENV ANDROID_BUILD_TOOLS_VERSION="29.0.3"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/home/$USER/android"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="2.2.1"
# ENV FLUTTER_VERSION="2.10.1"
# ENV FLUTTER_VERSION="2.8.1"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
# ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV FLUTTER_HOME="/home/$USER/flutter"
ENV FLUTTER_WEB_PORT="8090"
ENV FLUTTER_DEBUG_PORT="42000"
ENV FLUTTER_EMULATOR_NAME="flutter_emulator"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_HOME/bin:$PATH"

# install all dependencies
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install --yes --no-install-recommends openjdk-$JAVA_VERSION-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx sudo \
  neovim stow tmux ninja-build gettext libtool libtool-bin build-essential autoconf automake cmake g++ pkg-config unzip curl doxygen \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

# create user
RUN groupadd --gid $GID $USER \
  && useradd -s /bin/bash --uid $UID --gid $GID -m $USER \
  && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
  && chmod 0440 /etc/sudoers.d/$USER


RUN git clone https://github.com/neovim/neovim && cd neovim && make install && cd ..

USER $USER
WORKDIR /home/$USER

# Nvim and stuff
RUN git clone https://github.com/renerocksai/renerocksai.stow.git && mv .bashrc .bashrc.bak && cd renerocksai.stow && stow nvim bash git tmux && cd ..
RUN nvim --headless +PlugInstall +qa || true

# android sdk
RUN mkdir -p $ANDROID_SDK_ROOT \
  && mkdir -p /home/$USER/.android \
  && touch /home/$USER/.android/repositories.cfg \
  && curl -o android_tools.zip $ANDROID_TOOLS_URL \
  && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip \
  && rm android_tools.zip \
  && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/tools \
  && mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/tools \
  && mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/tools \
  && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
  && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" \
  && yes "y" | sdkmanager "platform-tools" \
  && yes "y" | sdkmanager "emulator" \
  && yes "y" | sdkmanager "system-images;android-$ANDROID_VERSION;google_apis_playstore;$ANDROID_ARCHITECTURE"

# flutter
RUN echo $FLUTTER_URL && curl -o flutter.tar.xz $FLUTTER_URL 
RUN mkdir -p $FLUTTER_HOME 
RUN tar xf flutter.tar.xz -C /home/$USER 
RUN rm flutter.tar.xz 
RUN flutter config --no-analytics 
RUN yes "y" | flutter doctor --android-licenses
RUN flutter upgrade
RUN flutter precache
RUN flutter doctor
RUN flutter emulators --create
RUN flutter update-packages
#
COPY entrypoint.sh /usr/local/bin/
COPY chown.sh /usr/local/bin/
COPY inside.sh /usr/local/bin/
COPY flutter-android-emulator.sh /usr/local/bin/flutter-android-emulator
# # ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
ENTRYPOINT [ "/usr/local/bin/inside.sh" ]

RUN nvim --headless +TSUpdateSync +qa
RUN cd renerocksai.stow && stow fonts && fc-cache -fv && cd ..
RUN echo 'alias tmux="tmux -2 -u"' >> .bashrc
RUN cd renerocksai.stow && git pull && cd ..
