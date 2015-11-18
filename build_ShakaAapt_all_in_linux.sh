#! /bin/bash
#43

export Project=ShakaAapt
export BUILD_NUMBER=$Project.$(date +%Y%m%d.%H%M%S)
export BinDir=ShakaAaptBin

export USE_CCACHE=1
export CCACHE_DIR=$(pwd)/.ccache
export OUT_DIR=out-x86_64
prebuilts/misc/linux-x86/ccache/ccache -M 50G
. build/envsetup.sh
lunch sdk-eng

rm -rf out-x86 out-x86_64

# linux-x86_64

OUT_DIR=out-x86_64 make -B BUILD_NUMBER=$BUILD_NUMBER LOCAL_MULTILIB=64 USE_NINJA=false aapt -j4
strip out-x86_64/host/linux-x86/bin/aapt
mkdir -p $BinDir/linux-x86_64/bin
cp out-x86_64/host/linux-x86/bin/aapt $BinDir/linux-x86_64/bin/aapt

#strip out-x86_64/host/linux-x86/lib64/libc++.so
#mkdir -p $BinDir/linux-x86_64/lib64
#cp out-x86_64/host/linux-x86/lib64/libc++.so $BinDir/linux-x86_64/lib64/libc++.so

# linux-x86

OUT_DIR=out-x86 make -B BUILD_NUMBER=$BUILD_NUMBER LOCAL_MULTILIB=32 USE_NINJA=false aapt -j4
strip out-x86/host/linux-x86/bin/aapt
mkdir -p $BinDir/linux-x86/bin
cp out-x86/host/linux-x86/bin/aapt $BinDir/linux-x86/bin/aapt

#strip out-x86/host/linux-x86/lib/libc++.so
#mkdir -p $BinDir/linux-x86/lib
#cp out-x86/host/linux-x86/lib/libc++.so $BinDir/linux-x86/lib/libc++.so

# windows-x86

OUT_DIR=out-x86 make -B winsdk-tools -j4 USE_NINJA=false
strip out-x86/host/windows-x86/bin/aapt.exe
mkdir -p $BinDir/windows-x86/bin
cp out-x86/host/windows-x86/bin/aapt.exe $BinDir/windows-x86/bin/aapt.exe
