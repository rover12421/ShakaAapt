#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

LOCAL_PATH:= $(call my-dir)

ubsan_rtl_files := \
    ubsan_diag.cc \
    ubsan_init.cc \
    ubsan_flags.cc \
    ubsan_handlers.cc \
    ubsan_value.cc \

ubsan_cxx_rtl_files := \
    ubsan_handlers_cxx.cc \
    ubsan_type_hash.cc \

ubsan_rtl_cppflags := \
    -fvisibility=hidden \
    -fno-exceptions \
    -std=c++11 \
    -Wall \
    -Werror \
    -Wno-unused-parameter \
    -Wno-non-virtual-dtor \

ubsan_rtl_c_includes := \
    external/compiler-rt/lib \

################################################################################
# Target modules

ifeq ($(TARGET_ARCH),arm)

include $(CLEAR_VARS)
LOCAL_MODULE := libubsan
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(ubsan_rtl_c_includes)
LOCAL_CPPFLAGS := $(ubsan_rtl_cppflags)
LOCAL_SRC_FILES := $(ubsan_rtl_files)
LOCAL_CXX_STL := none
LOCAL_SANITIZE := never
LOCAL_MULTILIB := both
include $(BUILD_STATIC_LIBRARY)

endif # ($(TARGET_ARCH),arm)

################################################################################
# Host modules

ifneq ($(HOST_OS),darwin)

include $(CLEAR_VARS)
LOCAL_MODULE := libubsan
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(ubsan_rtl_c_includes)
LOCAL_CPPFLAGS := $(ubsan_rtl_cppflags) -fno-rtti
LOCAL_SRC_FILES := $(ubsan_rtl_files)
LOCAL_CXX_STL := none
LOCAL_SANITIZE := never
LOCAL_MULTILIB := both
include $(BUILD_HOST_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libubsan_standalone
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(ubsan_rtl_c_includes)
LOCAL_CPPFLAGS := $(ubsan_rtl_cppflags) -fno-rtti
LOCAL_SRC_FILES := $(ubsan_rtl_files)
LOCAL_WHOLE_STATIC_LIBRARIES := libsan
LOCAL_CXX_STL := none
LOCAL_SANITIZE := never
LOCAL_MULTILIB := both
include $(BUILD_HOST_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libubsan_cxx
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(ubsan_rtl_c_includes)
LOCAL_CPPFLAGS := $(ubsan_rtl_cppflags)
LOCAL_SRC_FILES := $(ubsan_cxx_rtl_files)
LOCAL_SANITIZE := never
LOCAL_MULTILIB := both
include $(BUILD_HOST_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libubsan_standalone_cxx
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(ubsan_rtl_c_includes)
LOCAL_CPPFLAGS := $(ubsan_rtl_cppflags)
LOCAL_SRC_FILES := $(ubsan_cxx_rtl_files)
LOCAL_SANITIZE := never
LOCAL_MULTILIB := both
include $(BUILD_HOST_STATIC_LIBRARY)

endif
