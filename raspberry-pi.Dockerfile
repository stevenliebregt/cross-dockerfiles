# The only difference with https://github.com/cross-rs/cross/blob/main/docker/Dockerfile.armv7-unknown-linux-gnueabihf is
# that this is based of ubuntu 18.04 instead of 20.04

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV SCRIPTS_DIR=scripts

COPY $SCRIPTS_DIR/common.sh $SCRIPTS_DIR/lib.sh /
RUN /common.sh

COPY $SCRIPTS_DIR/cmake.sh /
RUN /cmake.sh

COPY $SCRIPTS_DIR/xargo.sh /
RUN /xargo.sh

RUN apt-get update && apt-get install --assume-yes --no-install-recommends \
    g++-arm-linux-gnueabihf \
    libc6-dev-armhf-cross

COPY $SCRIPTS_DIR/deny-debian-packages.sh /
RUN TARGET_ARCH=armhf /deny-debian-packages.sh \
    binutils \
    binutils-arm-linux-gnueabihf

COPY $SCRIPTS_DIR/qemu.sh /
RUN /qemu.sh arm softmmu

COPY $SCRIPTS_DIR/dropbear.sh /
RUN /dropbear.sh

COPY $SCRIPTS_DIR/linux-image.sh /
RUN /linux-image.sh armv7

COPY $SCRIPTS_DIR/linux-runner $SCRIPTS_DIR/base-runner.sh /
COPY $SCRIPTS_DIR/toolchain.cmake /opt/toolchain.cmake

ENV CROSS_TOOLCHAIN_PREFIX=arm-linux-gnueabihf-
ENV CROSS_SYSROOT=/usr/arm-linux-gnueabihf
ENV CROSS_TARGET_RUNNER="/linux-runner armv7hf"
ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER="$CROSS_TOOLCHAIN_PREFIX"gcc \
    CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_RUNNER="$CROSS_TARGET_RUNNER" \
    AR_armv7_unknown_linux_gnueabihf="$CROSS_TOOLCHAIN_PREFIX"ar \
    CC_armv7_unknown_linux_gnueabihf="$CROSS_TOOLCHAIN_PREFIX"gcc \
    CXX_armv7_unknown_linux_gnueabihf="$CROSS_TOOLCHAIN_PREFIX"g++ \
    CMAKE_TOOLCHAIN_FILE_armv7_unknown_linux_gnueabihf=/opt/toolchain.cmake \
    BINDGEN_EXTRA_CLANG_ARGS_armv7_unknown_linux_gnueabihf="--sysroot=$CROSS_SYSROOT" \
    QEMU_LD_PREFIX="$CROSS_SYSROOT" \
    RUST_TEST_THREADS=1 \
    PKG_CONFIG_PATH="/usr/lib/arm-linux-gnueabihf/pkgconfig/:${PKG_CONFIG_PATH}" \
    CROSS_CMAKE_SYSTEM_NAME=Linux \
    CROSS_CMAKE_SYSTEM_PROCESSOR=arm \
    CROSS_CMAKE_CRT=gnu \
    CROSS_CMAKE_OBJECT_FLAGS="-ffunction-sections -fdata-sections -fPIC -march=armv7-a -mfpu=vfpv3-d16"
