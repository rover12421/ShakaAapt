Build instruction:

  cd $NDK
  ./build/tools/download-toolchain-sources.sh /tmp/ndk-$USER/src
  ./build/tools/gen-platforms.sh --dst-dir=$NDK --ndk-dir=$NDK --overlay --arch=mips --gcc-version=4.8
  ./build/tools/build-gdbserver.sh /tmp/ndk-$USER/src $NDK -j32 mipsel-linux-android-4.8 --gdb-version=7.7

Current prebuilt version is against AOSP-toolchain/gdb/gdb-7.7
commit d447a02c56e29599468a19c409cee56f702746fe
