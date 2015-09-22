Build instruction:

  cd $NDK
  ./build/tools/download-toolchain-sources.sh /tmp/ndk-$USER/src
  ./build/tools/gen-platforms.sh --dst-dir=$NDK --ndk-dir=$NDK --overlay --arch=x86_64 --gcc-version=4.8
  ./build/tools/build-gdbserver.sh /tmp/ndk-$USER/src $NDK -j32 x86_64-4.8 --gdb-version=7.6

Current prebuilt version is against AOSP-toolchain/gdb/gdb-7.6
commit 37c2cd1af0dd58048d965bac278fc5d83fea65a0
