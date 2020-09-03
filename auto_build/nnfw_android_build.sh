#!/bin/bash

CURRENT_PATH=~/nfs/bash_script/auto_build
NNFW_PATH=~/nfs/nnfw

cd $NNFW_PATH

if [ -e Product ]; then
  echo "Message: Product directory already exists."
  read -p "Continue (y/n)?" choice
  case "$choice" in
    y|Y ) echo "Message: Continue with incremental build"
    ;;
    n|N ) echo "Message: Exit. Please remove or keep current Product directory"
          exit 1
    ;;
    * ) echo "Message: Invalid. Press Y/y/N/n"
        exit 1
    ;;
  esac
fi

cp Makefile.template Makefile

TARGET_OS=android \
CROSS_BUILD=1 \
BUILD_TYPE=release \
NDK_DIR=~/nfs/ndk \
make install

GIT_TAG="$( git describe --tags )"
DATE="$( date +%Y-%m-%d )"
NEW_NAME=Product_v${GIT_TAG}_android_${DATE}

echo "Message: Copying Product into $NEW_NAME"
cp -r Product $NEW_NAME

echo "Message: Generated $NEW_NAME "

