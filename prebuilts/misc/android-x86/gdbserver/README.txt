The Android platform gdb is built as part of the NDK build, from sources at https://android.googlesource.com/toolchain/gdb/.

To build it, follow the steps at https://android.googlesource.com/platform/ndk/+/master/README.md, and run `python checkbuild.py --module gdbserver`.

The current prebuilt version is built from the sources described by the manifest xml file in this directory.

