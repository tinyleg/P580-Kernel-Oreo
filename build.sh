#!/bin/bash

DTS=arch/arm64/boot/dts

export CROSS_COMPILER=/home/darius/Android/Kernel/toolchain/linaro/bin/aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=o

# Cleanup
make clean
make mrproper
# P580 Config
make exynos7870-gtanotexlwifi_defconfig
# p580 DTB
make exynos7870-gtanotexlwifi_kor_open_00.dtb exynos7870-gtanotexlwifi_kor_open_02.dtb
# Make zImage
make -j56

#sudo cp /home/darius/Android/Kernel/Sirikernel/arch/arm64/boot/Image /home/darius/Android/kernel/SiriKernel/Siri/out/Image

# Make dtb.img
DTS=arch/arm64/boot/dts
RDIR=$(pwd)


# Cleanup
#make clean && make mrproper
# P580 Config

make exynos7870-gtanotexlwifi_defconfig
make exynos7870-gtanotexlwifi_kor_open_00.dtb exynos7870-gtanotexlwifi_kor_open_02.dtb

# Make DT.img
./scripts/dtbTool/dtbTool -o ./boot.img-dtb -d $DTS/ -s 2048

# Cleaup
rm -rf $DTS/.*.tmp
rm -rf $DTS/.*.cmd
rm -rf $DTS/*.dtb

#sudo cp /home/darius/Android/Kernel/Sirikernel/boot.img-dtb /home/darius/Android/kernel/SiriKernel/Siri/out/dtb


#Make DT.img

#./tools/dtbtool -o ./arch/arm64/boot/dt.img -v -s 2048 -p ./scripts/dtc/ $DTS/

#./scripts/dtbTool/dtbTool -o ./boot.img-dtb -d $DTS/ -s 2048

# Cleaup
#rm -rf $DTS/.*.tmp
#rm -rf $DTS/.*.cmd
#rm -rf $DTS/*.dtb
