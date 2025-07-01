FROM docker.io/alpine:3.22 AS builder
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
    gettext-dev


RUN mkdir /source
COPY README.md /source
COPY COPYING /source
COPY CMakeLists.txt /source
COPY CMakePresets.json /source
COPY macros /source/macros
COPY dependencies /source/dependencies
COPY patch /source/patch
COPY package_deps_licenses.cmake.in /source
COPY check_musl.cmake /source

WORKDIR /source
RUN cmake --preset static-release
RUN cmake --build --preset static-release
RUN cpack --config build/CPackConfig.cmake --verbose -B dist
RUN rm -Rf dist/_CPack_Packages

FROM scratch

COPY --from=builder /source/dist /dist
