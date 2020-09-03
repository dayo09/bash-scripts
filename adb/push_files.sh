#!/bin/bash
set -x
SOURCE_NAME=$1 # put here
#DEST_NAME=model_bcq # $2 # put here

#[[ $SOURCE_NAME ]] || echo "Please put resource directory name in ../resource"
#[[ $DEST_NAME ]] || echo "Please put destination directory name"

SOURCE_ROOT=/home/dayo/nfs/bash_script/resource
DEST_ROOT=/data/local/tmp

SOURCE_PATH=${SOURCE_ROOT}/${SOURCE_NAME}
DEST_PATH=${DEST_ROOT}/${SOURCE_NAME}

askContinue() {
  read -p "Continue (y/n)?" choice
  case "$choice" in
  Y | y)
    echo "Continue.."
    ;;
  N | n)
    echo "Exit.."
    exit 1
    ;;
  *)
    echo "Please select between (y/n)"
    exit 1
    ;;
  esac
}

adb shell test ${DEST_PATH}
askContinue

adb shell mkdir ${DEST_PATH}

cd $SOURCE_PATH
SOURCE_FILES="$(ls $SOURCE_PATH)"

for i in $SOURCE_FILES; do
  echo "Pushing ${i} to ${DEST_PATH}..."
  adb shell mkdir ${DEST_PATH}/${i}
  adb push $i ${DEST_PATH}/${i}
done

echo "Finished."
set +x
