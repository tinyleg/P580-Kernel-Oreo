  #!/bin/bash
#
# Build Script V4.1
# For Exynos7870
# Coded by BlackMesa/AnanJaser1211 @2019
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Main Dir
CR_DIR=$(pwd)
# Define toolchan path
CR_TC=/home/darius/Android/Kernel/toolchain/linaro/bin/aarch64-linux-gnu-
# Define proper arch and dir for dts files
CR_DTS=arch/arm64/boot/dts
CR_DTS_TW=arch/arm64/boot/exynos7870_TW.dtsi
# Define boot.img out dir
CR_OUT=$CR_DIR/Siri/Out
CR_PRODUCT=$CR_DIR/Siri/Product
# Presistant A.I.K Location
CR_AIK=$CR_DIR/Siri/A.I.K
# Main Ramdisk Location
CR_RAMDISK_TW=$CR_DIR/Siri/TW
# Compiled image name and location (Image/zImage)
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
# Compiled dtb by dtbtool
CR_DTB=$CR_DIR/boot.img-dtb
# Kernel Name and Version
CR_VERSION=V2
CR_NAME=Siri_Kernel
# Thread count
CR_JOBS=$(nproc --all)
# Target android version and platform (7/n/8/o/9/p)
CR_ANDROID=o
CR_PLATFORM=8.1.0
# Target ARCH
CR_ARCH=arm64
# Current Date
CR_DATE=$(date +%Y%m%d)
# Init build
export CROSS_COMPILE=$CR_TC
# General init
export ANDROID_MAJOR_VERSION=$CR_ANDROID
export PLATFORM_VERSION=$CR_PLATFORM
export $CR_ARCH
##########################################
# Device specific Variables [SM-P580]
CR_DTSFILES_P580="exynos7870-gtanotexlwifi_kor_open_00.dtb exynos7870-gtanotexlwifi_kor_open_02.dtb"
CR_CONFG_P580=exynos7870-gtanotexlwifi_defconfig
CR_VARIANT_P580=P580
# Common configs
CR_CONFIG_TREBLE=treble_defconfig
CR_CONFIG_TW=tw_defconfig
CR_CONFIG_SPLIT=NULL
CR_CONFIG_KRAKEN=KRAKEN_defconfig
# Flashable Variables
FL_MODEL=NULL
FL_VARIANT=NULL
FL_DIR=$CR_DIR/Siri/Flashable
FL_EXPORT=$CR_DIR/Siri/Flashable_OUT
FL_SCRIPT=$FL_EXPORT/META-INF/com/google/android/updater-script
#####################################################

# Script functions

read -p "Clean source (y/n) > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "Clean Build"
     CR_CLEAN="1"
else
     echo "Dirty Build"
     CR_CLEAN="0"
fi

# Treble / TW
read -p "Variant? (1 (TW) | 2 (Treble) > " aud
if [ "$aud" = "Treble" -o "$aud" = "2" ]; then
     echo "Build Treble Variant"
     CR_MODE="2"
else
     echo "Build TW Variant"
     CR_MODE="1"
fi

BUILD_CLEAN()
{
if [ $CR_CLEAN = 1 ]; then
     echo " "
     echo " Cleaning build dir"
     make clean && make mrproper
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7870.dtsi
     rm -rf $CR_OUT/*.img
     rm -rf $CR_OUT/*.zip
fi
if [ $CR_CLEAN = 0 ]; then
     echo " "
     echo " Skip Full cleaning"
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7870.dtsi
fi
}

BUILD_IMAGE_NAME()
{
	CR_IMAGE_NAME=$CR_NAME-$CR_VERSION-$CR_VARIANT-$CR_DATE

  # Flashable_script
  if [ $CR_VARIANT = $CR_VARIANT_P580-TW ]; then
    FL_VARIANT="P580-TW"
    FL_MODEL=P580
  fi
}


BUILD_OUT()
{
    echo " "
    echo "----------------------------------------------"
    echo "$CR_VARIANT kernel build finished."
    echo "Compiled DTB Size = $sizdT Kb"
    echo "Kernel Image Size = $sizT Kb"
    echo "Boot Image   Size = $sizkT Kb"
    echo "Image Generated at $CR_PRODUCT/$CR_IMAGE_NAME.img"
    echo "Zip Generated at $CR_PRODUCT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip"
    echo "Press Any key to end the script"
    echo "----------------------------------------------"
}

BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building zImage for $CR_VARIANT"
	export LOCALVERSION=-$CR_IMAGE_NAME
  cp $CR_DTB_MOUNT $CR_DTS/exynos7870.dtsi
	echo "Make $CR_CONFIG"
	make $CR_CONFIG
	make -j$CR_JOBS
	if [ ! -e $CR_KERNEL ]; then
	exit 0;
	echo "Image Failed to Compile"
	echo " Abort "
	fi
    du -k "$CR_KERNEL" | cut -f1 >sizT
    sizT=$(head -n 1 sizT)
    rm -rf sizT
	echo " "
	echo "----------------------------------------------"
}
BUILD_DTB()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building DTB for $CR_VARIANT"
	# This source compiles dtbs while doing Image
	./scripts/dtbTool/dtbTool -o $CR_DTB -d $CR_DTS/ -s 2048
	if [ ! -e $CR_DTB ]; then
    exit 0;
    echo "DTB Failed to Compile"
    echo " Abort "
	fi
	rm -rf $CR_DTS/.*.tmp
	rm -rf $CR_DTS/.*.cmd
	rm -rf $CR_DTS/*.dtb
  rm -rf $CR_DTS/exynos7870.dtsi
    du -k "$CR_DTB" | cut -f1 >sizdT
    sizdT=$(head -n 1 sizdT)
    rm -rf sizdT
	echo " "
	echo "----------------------------------------------"
}
PACK_BOOT_IMG()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Boot.img for $CR_VARIANT"
	# Copy Ramdisk
	cp -rf $CR_RAMDISK/* $CR_AIK
	# Move Compiled kernel and dtb to A.I.K Folder
	mv $CR_KERNEL $CR_AIK/split_img/boot.img-zImage
	mv $CR_DTB $CR_AIK/split_img/boot.img-dtb
	# Create boot.img
	$CR_AIK/repackimg.sh
	# Remove red warning at boot
	echo -n "SEANDROIDENFORCE" » $CR_AIK/image-new.img
  # Copy boot.img to Production folder
	cp $CR_AIK/image-new.img $CR_PRODUCT/$CR_IMAGE_NAME.img
	# Move boot.img to out dir
	mv $CR_AIK/image-new.img $CR_OUT/$CR_IMAGE_NAME.img
	du -k "$CR_OUT/$CR_IMAGE_NAME.img" | cut -f1 >sizkT
	sizkT=$(head -n 1 sizkT)
	rm -rf sizkT
	echo " "
	$CR_AIK/cleanup.sh
}

PACK_FLASHABLE()
{

  echo "----------------------------------------------"
  echo "$CR_NAME $CR_VERSION Flashable Generator"
  echo "----------------------------------------------"
	echo " "
	echo " Target device : $CR_VARIANT "
  echo " Target image $CR_OUT/$CR_IMAGE_NAME.img "
  echo " Prepare Temporary Dirs"
  FL_DEVICE=$FL_EXPORT/Siri/device/$FL_MODEL/boot.img
  echo " Copy $FL_DIR to $FL_EXPORT"
  rm -rf $FL_EXPORT
  mkdir $FL_EXPORT
  cp -rf $FL_DIR/* $FL_EXPORT
  echo " Generate updater for $FL_VARIANT"
  sed -i 's/FL_NAME/ui_print("* '$CR_NAME'");/g' $FL_SCRIPT
  sed -i 's/FL_VERSION/ui_print("* '$CR_VERSION'");/g' $FL_SCRIPT
  sed -i 's/FL_VARIANT/ui_print("* For '$FL_VARIANT' ");/g' $FL_SCRIPT
  sed -i 's/FL_DATE/ui_print("* Compiled at '$CR_DATE'");/g' $FL_SCRIPT
  echo " Copy Image to $FL_DEVICE"
  cp $CR_OUT/$CR_IMAGE_NAME.img $FL_DEVICE
  echo " Packing zip"
  # TODO: FInd a better way to zip
  # TODO: support multi-compile
  # TODO: Conditional
  cd $FL_EXPORT
  zip -r $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip .
  cd $CR_DIR
  rm -rf $FL_EXPORT
  # Copy zip to production
  cp $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip $CR_PRODUCT
  # Move out dir to BUILD_OUT
  # Respect CLEAN build rules
  BUILD_CLEAN
}

# Main Menu
clear
echo "----------------------------------------------"
echo "$CR_NAME $CR_VERSION Build Script"
echo "----------------------------------------------"
PS3='Please select your option (1-1): '
menuvar=("SM-P580" "Build_All" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "SM-P580")
            clear
            echo "Starting $CR_VARIANT_P580kernel build..."
            CR_CONFIG=$CR_CONFG_P580
            CR_DTSFILES=$CR_DTSFILES_P580
            # Build Oreo WiFi HAL
            export ANDROID_MAJOR_VERSION=$CR_ANDROID
            export PLATFORM_VERSION=$CR_PLATFORM
            if [ $CR_MODE = "1" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TW
              CR_VARIANT=$CR_VARIANT_P580-TW
              CR_RAMDISK=$CR_RAMDISK_TW
              CR_DTB_MOUNT=$CR_DTS_TW
            else
              echo " Building TW variant "
              CR_CONFIG_USB=$CR_CONFIG_TW
              CR_VARIANT=$CR_VARIANT_P580-TW
              CR_RAMDISK=$CR_RAMDISK_TW
              CR_DTB_MOUNT=$CR_DTS_TW
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo " "
            echo " "
            echo " compilation finished "
            echo " Targets at $CR_OUT"
            echo " "
            echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
