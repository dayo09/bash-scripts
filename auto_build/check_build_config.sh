#!/bin/bash

function usage() {
  echo "usage: <command> options:<--one|--nnfw>"
  echo "  --one   : check ONE's cmake configuration file"
  echo "  --nnfw  : check NNFW's cmake configuration file"
  exit 1
}

function GetOptions() {
  if [[ ! $@ =~ ^\-.+ ]]; then
    usage
  fi

  for i in "$@"; do
    case $i in
    --help)
      usage
      ;;
    --one)
      ROOT_PATH=~/nfs/ONE
      ;;
    --nnfw)
      ROOT_PATH=~/nfs/nnfw
      ;;
    *)
      usage
      ;;
    esac
  done
}

function CheckRuyEnabled() {
  # Check RUY_PROFILE_ENABLED
  CFGFLAGS_FILE_PATH=$ROOT_PATH/infra/nnfw/cmake/CfgOptionFlags.cmake
  CFGFLAGS_FILE_NAME=$(basename $CFGFLAGS_FILE_PATH)
  CFGFLAGS_FILE_SAVED=$CURRENT_PATH/$CFGFLAGS_FILE_NAME/Enable_RuyProfile

  [[ -e CFGFLAGS_FILE_PATH ]] || echo "Incorrect file path, ${CFGFLAGS_FILE_PATH} not exist" && exit 1
  [[-e CFGFLAGS_FILE_SAVED ]] || echo "Incorrect file path, ${CFGFLAGS_FILE_SAVED} not exist" && exit 1

  if [ "$(diff $CFGFLAGS_FILE_PATH $CFGFLAGS_FILE_SAVED)" ]; then
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
  else
    echo "Ruy on ${ROOT_PATH} is enabled"
  fi
}

GetOptions "$@"

CURRENT_PATH=~/nfs/bash_script/auto_build

CheckRuyEnabled

set +x
