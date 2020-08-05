FROM google/dart:2

# Add bin location to path
ENV PATH="$PATH":"/root/.pub-cache/bin"
ENV FLUTTER_VERSION="1.17.5-stable"
ENV FLUTTER_HOME="${PWD}/flutter"

ARG USERNAME=flutter
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install git openssh-client less iproute2 procps lsb-release curl tar unzip \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install flutter and enable plateform specific build
RUN curl -sSLo flutter.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz \
    && tar xf flutter.tar.xz \
    && rm flutter.tar.xz \
    && echo "export PATH=${PATH}:${FLUTTER_HOME}/bin" >> /home/${USERNAME}/.bashrc \
    && export PATH=${PATH}:${FLUTTER_HOME}/bin \
    && flutter channel master \
    && flutter upgrade \
    && flutter config --enable-web \
    && flutter config --enable-macos-desktop \
    && flutter config --enable-linux-desktop \
    && flutter precache \
    && chown ${USER_UID}:${USER_UID} -R ${FLUTTER_HOME}

ENV PATH $PATH:$FLUTTER_HOME/bin

ENTRYPOINT [ "flutter" ]
