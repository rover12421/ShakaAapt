#!/bin/bash -e

# Copy binaries
for b in bin/*; do
  file=`basename $b`
  # Don't copy symlinks like clang++ or directories
  if test -h $b || test -d $b; then
    echo Skipping $file
  else
    echo Copying $file
    cp -a `find ${ANDROID_HOST_OUT}/bin -name $file` $b
    strip $b
  fi
done

# Copy static analyzer scripts.
echo Copying static analyzer tools
rm -rf tools/*
mkdir -p tools
cp -ar ${ANDROID_BUILD_TOP}/external/clang/tools/scan-build tools
cp -ar ${ANDROID_BUILD_TOP}/external/clang/tools/scan-view tools

# Copy libraries
echo Copying libc++.so
cp -a ${ANDROID_HOST_OUT}/lib/libc++.so lib/
cp -a ${ANDROID_HOST_OUT}/lib64/libc++.so lib64/

# Copy header files
rm -rf lib/clang/*/include/*
for i in `find ${ANDROID_BUILD_TOP}/external/clang/lib/Headers -mindepth 1 ! -name \*.mk -a ! -name Makefile -a ! -name CMakeLists.txt`; do
  echo Copying `basename $i`
  cp -a $i lib/clang/*/include/
done

# Copy over stdatomic.h from bionic
echo Copying stdatomic.h
cp -a ${ANDROID_BUILD_TOP}/bionic/libc/include/stdatomic.h lib/clang/*/include/

echo Copying arm_neon.h
cp -a `find ${ANDROID_PRODUCT_OUT} -name arm_neon.h | head -n 1` lib/clang/*/include

function copy_profile_rt() {
  target=$1
  arch=$2
  obj=${ANDROID_BUILD_TOP}/out/target/product/${target}/obj/STATIC_LIBRARIES
  libdir=$(echo lib/clang/*)/lib/linux
  lib=${libdir}/libclang_rt.profile-${arch}-android.a
  cp -a ${obj}/libprofile_rt_intermediates/libprofile_rt.a ${lib}
}

function copy_host_profile_rt() {
  arch=$1
  obj_suffix=$2
  obj=${ANDROID_BUILD_TOP}/out/host/linux-x86/obj$obj_suffix/STATIC_LIBRARIES
  libdir=$(echo lib/clang/*)/lib/linux
  lib=${libdir}/libclang_rt.profile-${arch}.a
  cp -a ${obj}/libprofile_rt_intermediates/libprofile_rt.a ${lib}
}

copy_profile_rt generic arm
copy_profile_rt generic_arm64 aarch64
copy_profile_rt generic_mips mipsel
copy_profile_rt generic_mips64 mips64el
copy_profile_rt generic_x86 i686
copy_profile_rt generic_x86_64 x86_64

copy_host_profile_rt x86_64
copy_host_profile_rt i686 32

sh update-sanitizers.sh
