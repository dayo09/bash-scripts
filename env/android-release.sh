#!/bin/bash

export TARGET_OS=android
export TARGET_ARCH=aarch64
export CROSS_BUILD=1
export BUILD_TYPE=release
export NDK_DIR="~/nfs/ndk"
export EXT_HDF5_DIR="~/nfs/hdf5"
export EXT_ACL_FOLDER="~/nfs/arm_compute-v20.05-bin-android/lib/android-arm64-v8a-neon-cl"
export BACKENDS="cpu"

echo "cpu is set as backend"

