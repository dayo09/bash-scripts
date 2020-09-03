#!/bin/bash

export TARGET_ARCH=armv7l
export CROSS_BUILD=1
export BUILD_TYPE=debug
export ROOTFS_DIR=$(pwd)/tools/cross/rootfs/arm
export BACKENDS="cpu"

echo "cpu is set as backend"
