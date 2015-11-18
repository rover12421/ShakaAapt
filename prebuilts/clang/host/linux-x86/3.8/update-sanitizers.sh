#!/bin/bash -e

echo Copying sanitizer headers
CLANGVER=$(echo lib/clang/* | cut -d ' ' -f 1)
INCDEST=${CLANGVER}/include
cp -a ${ANDROID_BUILD_TOP}/external/compiler-rt/include/sanitizer ${INCDEST}

echo Copying sanitizer libraries
LIBDEST=${CLANGVER}/lib/linux
OBJ32=${ANDROID_HOST_OUT}/obj32/STATIC_LIBRARIES
OBJ64=${ANDROID_HOST_OUT}/obj/STATIC_LIBRARIES

LIBS='libasan libasan_cxx libubsan_standalone libubsan_standalone_cxx'
for lib in $LIBS; do
  libname=${lib:3} # Strip 'lib' prefix.
  lib32=${LIBDEST}/libclang_rt.${libname}-i686.a
  lib64=${LIBDEST}/libclang_rt.${libname}-x86_64.a

  cp -a ${OBJ32}/${lib}_intermediates/${lib}.a ${lib32}
  cp -a ${OBJ64}/${lib}_intermediates/${lib}.a ${lib64}
done

LIBS64='libtsan libtsan_cxx'
for lib in $LIBS64; do
  libname=${lib:3} # Strip 'lib' prefix.
  lib64=${LIBDEST}/libclang_rt.${libname}-x86_64.a

  cp -a ${OBJ64}/${lib}_intermediates/${lib}.a ${lib64}
done

cp -a ${ANDROID_BUILD_TOP}/out/target/product/generic/system/lib/libclang_rt.asan-arm-android.so ${LIBDEST}
cp -a ${ANDROID_BUILD_TOP}/out/target/product/generic_arm64/system/lib64/libclang_rt.asan-arm64-android.so ${LIBDEST}
