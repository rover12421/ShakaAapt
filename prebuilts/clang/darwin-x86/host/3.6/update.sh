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
cp -a ${ANDROID_BUILD_TOP}/external/clang/tools/scan-build tools
cp -a ${ANDROID_BUILD_TOP}/external/clang/tools/scan-view tools

# Copy libraries
echo Copying libc++.dylib
cp -a ${ANDROID_HOST_OUT}/lib/libc++.dylib lib/
cp -a ${ANDROID_HOST_OUT}/lib64/libc++.dylib lib64/

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
cp -a `find ${ANDROID_PRODUCT_OUT} -name arm_neon.h` lib/clang/*/include

