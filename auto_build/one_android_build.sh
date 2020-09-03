#!/bin/bash

CURRENT_PATH=~/nfs/bash_script/auto_build
ROOT_PATH=~/nfs/ONE

function help() {
  echo "[Usage] Build ~/nfs/ONE with android configuration"
  echo "[Options]"
  echo "--ruy_profile : enable ruy profile option"
}

# Check whether to enable RuyProfile
for i in "$@"; do
  case $i in
  --ruy_profile)
    ENABLE_RUY_PROFILE=1
    ;;
  --help)
    help
    exit 1
    ;;
  esac
done

CFGFLAGS_FILE_PATH=$ROOT_PATH/infra/nnfw/cmake/CfgOptionFlags.cmake
CFGFLAGS_FILE_NAME=$(basename $CFGFLAGS_FILE_PATH)
CFGFLAGS_FILE_SAVED=$CURRENT_PATH/$CFGFLAGS_FILE_NAME/Enable_RuyProfile
if [ $ENABLE_RUY_PROFILE ]; then
  # Copying CfgoptionFlags.cmake to enable ```option(PROFILE_RUY "Enable ruy library profiling" ON)````
  if [ "$(diff $CFGFLAGS_FILE_PATH $CFGFLAGS_FILE_SAVED)" ]; then
    echo "Message : ${CFGFLAGS_FILE_NAME} is not equivalent"

    read -p "Message: Show diff? (y/n)" choice
    case "$choice" in
    y | Y)
      diff $CFGFLAGS_FILE_PATH $CFGFLAGS_FILE_SAVED
      ;;
    n | N) ;;

    *)
      echo "Message: Invalid input. Press Y/y/N/n"
      ;;
    esac

    read -p "Message: Copy ${CFGFLAGS_FILE_NAME} file? (Y/n)" choice
    case "$choice" in
    y | Y)
      echo "Message: Copying..."
      cp $CFGFLAGS_FILE_SAVED $CFGFLAGS_FILE_PATH
      ;;
    n | N) ;;

    *)
      echo "Message: Invalid input. Press Y/y/N/n"
      ;;
    esac
  fi
fi

OPTION_FILE_PATH=$ROOT_PATH/infra/nnfw/cmake/options/options_aarch64-android.cmake
OPTION_FILE_NAME=$(basename $OPTION_FILE_PATH)
OPTION_FILE_SAVED=$CURRENT_PATH/$OPTION_FILE_NAME/Enable_AndroidBuild

# Copying options_aarch64-android.cmake to set NNPACKAGE_RUN build ON
if [ "$(diff $OPTION_FILE_SAVED $OPTION_FILE_PATH)" ]; then
  echo "Message : ${OPTION_FILE_NAME} is not equivalent"

  read -p "Message: Show diff? (Y/n)" choice
  case "$choice" in
  y | Y)
    diff $OPTION_FILE_PATH $OPTION_FILE_SAVED
    ;;
  n | N) ;;

  *)
    echo "Message: Invalid input. Press Y/y/N/n"
    ;;
  esac

  read -p "Message: Copy ${OPTION_FILE_NAME} file? (Y/n)" choice
  case "$choice" in
  y | Y)
    echo "Message: Copying..."
    cp $OPTION_FILE_SAVED $OPTION_FILE_PATH
    ;;
  n | N) ;;

  *)
    echo "Message: Invalid input. Press Y/y/N/n"
    ;;
  esac
fi

cd $ROOT_PATH
cp Makefile.template Makefile

if [ -e Product ]; then
  echo "Message: Product directory already exists."

  read -p "Message: Continue by incremental build? (y/n)" choice
  case "$choice" in
  y | Y) echo "Message: Continue by overwriting ./Product" ;;
  n | N)
    echo "Message: Exit"
    exit 1
    ;;
  *) echo "Message: invalid" ;;
  esac
fi

echo "Message: Build Start (android, cross, release)"
TARGET_OS=android \
  CROSS_BUILD=1 \
  BUILD_TYPE=release \
  NDK_DIR=~/nfs/ndk \
  EXT_HDF5_DIR=/home/dayo/nfs/hdf5 \
  make install

GIT_TAG="$(git describe --tags)"
DATE="$(date +%Y-%m-%d)"
NEW_NAME=Product_v${GIT_TAG}_android_${DATE}
cp -r Product $NEW_NAME
echo "Message: ${NEW_NAME} is generated."
