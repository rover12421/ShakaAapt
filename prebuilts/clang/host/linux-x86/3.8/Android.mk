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

LOCAL_PATH := $(call my-dir)

# Use these prebuilts unless we are actually building from a newly rebased
# LLVM. This variable should be set as part of the build_profile_rt.sh script.
ifneq (true,$(FORCE_BUILD_SANITIZER_SHARED_OBJECTS))

include $(CLEAR_VARS)
LOCAL_MODULE := libclang_rt.asan-arm-android
LOCAL_SRC_FILES := lib/clang/3.8/lib/linux/$(LOCAL_MODULE).so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_TARGET_ARCH := arm arm64
LOCAL_MULTILIB := 32
LOCAL_MODULE_PATH_32 := $(TARGET_OUT)/lib
LOCAL_SANITIZE := never
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := libclang_rt.asan-arm64-android
LOCAL_SRC_FILES := lib/clang/3.8/lib/linux/$(LOCAL_MODULE).so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_TARGET_ARCH := arm64
LOCAL_MODULE_PATH_64 := $(TARGET_OUT)/lib64
LOCAL_SANITIZE := never
include $(BUILD_PREBUILT)

endif
