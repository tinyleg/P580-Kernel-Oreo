#!/bin/bash

export CROSS_COMPILER=/home/darius/Android/Kernel/toolchain/linaro/bin/aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=o
make exynos7870-gtanotexlwifi_defconfig
make -j5
rm -rf mod
mkdir mod
cp `find ./ | grep .ko$` modules.order mod/
