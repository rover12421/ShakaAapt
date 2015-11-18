#!/bin/bash -e

source version

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

# Copy license files.
# Need to make sure we get all the MODULE_LICENSE_* files used and concatenate
# all the NOTICE files (all of which differ slightly).
cp -a ${ANDROID_BUILD_TOP}/external/clang/MODULE_LICENSE_* .
cp -a ${ANDROID_BUILD_TOP}/external/llvm/MODULE_LICENSE_* .
cp -a ${ANDROID_BUILD_TOP}/external/compiler-rt/MODULE_LICENSE_* .
cp -a ${ANDROID_BUILD_TOP}/external/libcxx/MODULE_LICENSE_* .
cp -a ${ANDROID_BUILD_TOP}/external/libcxxabi/MODULE_LICENSE_* .

cp -a ${ANDROID_BUILD_TOP}/external/clang/NOTICE .
echo >> NOTICE
cat ${ANDROID_BUILD_TOP}/external/llvm/NOTICE >> NOTICE
echo >> NOTICE
cat ${ANDROID_BUILD_TOP}/external/libcxx/NOTICE >> NOTICE
echo >> NOTICE
cat ${ANDROID_BUILD_TOP}/external/libcxxabi/NOTICE >> NOTICE
echo >> NOTICE
cat ${ANDROID_BUILD_TOP}/external/compiler-rt/NOTICE >> NOTICE

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
rm -rf lib/clang/*
mkdir -p lib/clang/${MAJOR}.${MINOR}/include
#mkdir -p lib/clang/${MAJOR}.${MINOR}/lib/darwin
for i in `find ${ANDROID_BUILD_TOP}/external/clang/lib/Headers -mindepth 1 ! -name \*.mk -a ! -name Makefile -a ! -name CMakeLists.txt`; do
  echo Copying `basename $i`
  cp -a $i lib/clang/*/include/
done

# Copy over stdatomic.h from bionic
echo Copying stdatomic.h
cp -a ${ANDROID_BUILD_TOP}/bionic/libc/include/stdatomic.h lib/clang/*/include/

echo Copying arm_neon.h
cp -a `find ${ANDROID_PRODUCT_OUT} -name arm_neon.h | head -n 1` lib/clang/*/include

# Create symlink for appropriately versioned clang
cd lib/clang/
ln -s ${MAJOR}.${MINOR} ${MAJOR}.${MINOR}.${PATCH}
cd -

