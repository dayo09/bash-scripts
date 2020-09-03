#!/bin/bash
set -x
BUILD_NAME=$1

if [ -z "$BUILD_NAME" ] ; then
  echo "
  Please give resource name as the 1st argument

  [Example] ./adb/push_one.sh v1.8.0-android-perinnath-patch
  [Available Lists]
  " 
  ls "resource"
  exit 1
fi

SOURCE_ROOT=/home/dayo/nfs/bash_script/resource
ADB_ROOT=/data/local/tmp

SOURCE_NNPKG_RUN_PATH=$SOURCE_ROOT/$BUILD_NAME/nnpackage_run
SOURCE_LIB_PATH=$SOURCE_ROOT/$BUILD_NAME/lib
SOURCE_BIN_PATH=$SOURCE_ROOT/$BUILD_NAME/bin
ADB_PATH=$ADB_ROOT/${BUILD_NAME}
ADB_LIB_PATH=$ADB_PATH/lib
ADB_BIN_PATH=$ADB_PATH/bin

askDelete() {
  read -p "Delete ${ADB_PATH}? And make new? (y/n)" choice
  case "$choice" in
  Y | y)
    echo "Deleting ${ADB_PATH}"
    adb shell rm -r ${ADB_PATH}
    ;;
  N | n)
    echo "Exit."
    Exit 1
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

adb shell test ${ADB_PATH}
askDelete
adb shell mkdir ${ADB_PATH} ${ADB_LIB_PATH} ${ADB_BIN_PATH}

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

cd $SOURCE_LIB_PATH
SOURCE_LIB_FILES="$(ls $SOURCE_LIB_PATH)"

for i in $SOURCE_LIB_FILES; do
  echo "Pushing ${i} to ${ADB_LIB_PATH}..."
  adb push $i $ADB_LIB_PATH
done

cd $SOURCE_BIN_PATH
SOURCE_BIN_FILES="$(ls $SOURCE_BIN_PATH)"

for i in $SOURCE_BIN_FILES; do
  echo "Pushing ${i} to ${ADB_BIN_PATH}..."
  adb push $i $ADB_BIN_PATH
done

echo "Finished."
set +x
