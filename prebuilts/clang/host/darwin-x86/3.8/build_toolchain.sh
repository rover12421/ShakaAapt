#!/bin/bash -e

export FORCE_BUILD_LLVM_COMPONENTS=true
export SKIP_LLVM_TESTS=true

CLANG_DIR=$ANDROID_BUILD_TOP/external/clang
LLVM_DIR=$ANDROID_BUILD_TOP/external/llvm
COMPILER_RT_DIR=$ANDROID_BUILD_TOP/external/compiler-rt
LIBCXX_DIR=$ANDROID_BUILD_TOP/external/libcxx

#NUM_CORES=`cat /proc/cpuinfo | grep processor | tail -n 1 | cut -f 2 -d :`
#NUM_CORES=$(($NUM_CORES+1))
NUM_CORES=12
echo "Using $NUM_CORES cores"

cd $ANDROID_BUILD_TOP
source build/envsetup.sh
lunch aosp_arm-userdebug

HOST_BIN=out/host/darwin-x86/bin
INTERESTING="\
  $HOST_BIN/clang \
  $HOST_BIN/FileCheck \
  $HOST_BIN/llvm-as \
  $HOST_BIN/llvm-dis \
  $HOST_BIN/llvm-link \
  out/target/product/generic/obj/include/clang/arm_neon.h \
"



make -j$NUM_CORES $INTERESTING || exit 1
cd $LLVM_DIR && mma -j$NUM_CORES || exit 1
cd $CLANG_DIR && mma -j$NUM_CORES || exit 1
cd $LIBCXX_DIR && mma -j$NUM_CORES || exit 1
cd $COMPILER_RT_DIR && mma -j$NUM_CORES || exit 1

exit 0
