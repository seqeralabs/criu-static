FROM docker.io/alpine:3.22 AS builder

ARG USERNAME=criudev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apk update
RUN apk add cmake \
    make \
    clang \
    llvm \
    git \
    autoconf \
    automake \
    libtool \
    m4 \
    flex \
    bison \
    pkgconfig \
    bash \
    linux-headers \
    patch \
    coreutils \
    gettext \
    gettext-dev \
    gtk-doc

RUN apk add sudo
RUN adduser -D -u $USER_UID -g $USER_GID $USERNAME \
    && addgroup $USERNAME wheel \
    && sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

USER $USERNAME
