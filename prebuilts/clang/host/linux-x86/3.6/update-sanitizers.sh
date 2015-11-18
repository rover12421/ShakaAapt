#!/bin/bash -e

echo Copying sanitizer headers
cp -a ${ANDROID_BUILD_TOP}/external/compiler-rt/include/sanitizer lib/clang/*/include/

echo Copying sanitizer libraries
LIBDEST=$(echo lib/clang/*)/lib/linux
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
