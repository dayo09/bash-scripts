#!/bin/bash

TARGET_OS=android \
TARGET_ARCH=aarch64 \
CROSS_BUILD=1 \
BUILD_TYPE=release \
NDK_DIR="~/nfs/ndk" \
EXT_HDF5_DIR="~/nfs/hdf5" \
EXT_ACL_FOLDER="~/nfs/arm_compute-v20.05-bin-android/lib/android-arm64-v8a-neon-cl" \
make configure build install

echo "android, release : acl enable"

