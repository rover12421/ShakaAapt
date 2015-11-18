#!/bin/bash -e

export SKIP_LLVM_TESTS=true
export FORCE_BUILD_SANITIZER_SHARED_OBJECTS=true

build_profile_rt() {
  echo Building for target $1
  cd $ANDROID_BUILD_TOP
  source build/envsetup.sh
  lunch $1

  # Build only compiler-rt to get the runtime libraries
  echo Building compiler-rt for target $1
  cd $ANDROID_BUILD_TOP/external/compiler-rt && mma -j$NUM_CORES || exit 1
}

# Only build the host tools once
cd $ANDROID_BUILD_TOP
source build/envsetup.sh
lunch aosp_arm64-userdebug
# Build only llvm, clang and compiler-rt
cd $ANDROID_BUILD_TOP/external/llvm && mma -j$NUM_CORES || exit 1
cd $ANDROID_BUILD_TOP/external/clang && mma -j$NUM_CORES || exit 1
cd $ANDROID_BUILD_TOP/external/compiler-rt && mma -j$NUM_CORES || exit 1

build_profile_rt aosp_arm64-userdebug
build_profile_rt aosp_arm-userdebug
build_profile_rt aosp_mips-userdebug
build_profile_rt aosp_mips64-userdebug
build_profile_rt aosp_x86-userdebug
build_profile_rt aosp_x86_64-userdebug
