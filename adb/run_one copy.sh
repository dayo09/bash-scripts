#!/bin/bash

##############################################################################
################################ Settings ####################################

BINARY_TITLE=v1.8.0-android-periannath-patch
BACKENDS="cpu"
MODEL="model_bcq_after_7.30"

MODEL_LIST=("joint" "pred" "tran")
QUANT_LIST=("3" "5" "q" "f")

LOG_LATENCY=true
LOG_MEMORY=true

RUY_THREADS=1

##############################################################################
##############################################################################
########################### Do not edit below ################################

## Generate Test List
TEST_LIST=()
for m in ${MODEL_LIST[@]}; do
  for q in ${QUANT_LIST[@]}; do
    TEST_LIST+=(${m}${q})
  done
done

## Generate Log Directory & Readme
DATE="$(date +%Y-%m-%d_%T)"
LOG_TITLE=${BINARY_TITLE}/${DATE}
LOG_PATH=~/nfs/bash_script/log/${LOG_TITLE}
LOG_README="${LOG_PATH}/README.md"

mkdir -p ${LOG_PATH}

[[ -e "${LOG_README}" ]] && echo "Log directory ${LOG_PATH} is not empty." && exit 1

touch "${LOG_README}"
echo "- Date : ${DATE}" >>"${LOG_README}"
echo "- Runtime : ONE" >>"${LOG_README}"
echo "- Binary : resource/${BINARY_TITLE}" >>"${LOG_README}"
echo "- Backend : ${BACKENDS}" >>"${LOG_README}"
echo "- Model : ${MODEL}" >>"${LOG_README}"
echo "- Test Model List : ${TEST_LIST[@]}" >>"${LOG_README}"
echo "- Log Enabled : Latency(${LOG_LATENCY}) Memory(${LOG_MEMORY})" >>"${LOG_README}"
echo "---------------------------------------------------------" >>"${LOG_README}"
echo "- RUY_THREADS : ${RUY_THREADS}" >>"${LOG_README}"

## Set ADB Path to run & log
ADB_ROOT=/data/local/tmp
ADB_ONE_PATH=$ADB_ROOT/${BINARY_TITLE}
ADB_ONE_LIB_PATH=$ADB_ONE_PATH/lib
ADB_ONE_NNPKG_RUN_PATH=$ADB_ONE_PATH/bin/nnpackage_run

MODEL_ROOT=${ADB_ROOT}/${MODEL}

if [ $LOG_LATENCY = true ]; then
  LOG_LATENCY_PATH=${LOG_PATH}/latency
  mkdir -p $LOG_LATENCY_PATH
fi

if [ $LOG_MEMORY = true ]; then
  LOG_MEMORY_PATH=${LOG_PATH}/memory
  mkdir -p $LOG_MEMORY_PATH
fi


RUN(){
LATENCY_RUN_COMMAND="adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -w20 -r500"
MEMORY_RUN_COMMAND="adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -m1 -w1 -r5 "

for model_file in ${TEST_LIST[@]}; do
  "${LATENCY_RUN_COMMAND} ${MODEL_ROOT}/${model_file}" >${LOG_LATENCY_PATH}/${model_file}.log
  sleep 5
  "${MEMORY_RUN_COMMAND} ${MODEL_ROOT}/${model_file}" >${LOG_MEMORY_PATH}/${model_file}.log
  sleep 15
done
}

exit 1

model_load_warmup() {
  LOG_MEMORY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/${BACKENDS}/memory
  LOG_LATENCY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/${BACKENDS}/latency
  mkdir -p $LOG_MEMORY_PATH
  mkdir -p $LOG_LATENCY_PATH

  for model in "joint" "pred"; do
    for quant in "3"; do
      model_file=bcq_${model}${quant}
      #adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -w20 -r500 ${MODEL_ROOT}/${model_file} >${LOG_LATENCY_PATH}/${model_file}.log
      adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -w20 -r200 ${MODEL_ROOT}/${model_file} # >${LOG_MEMORY_PATH}/${model_file}.log
      #sleep 15
    done
  done
}

run() {
  LOG_MEMORY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/${MODEL}/${BACKENDS}/memory
  LOG_LATENCY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/${MODEL}/${BACKENDS}/latency
  mkdir -p $LOG_MEMORY_PATH
  mkdir -p $LOG_LATENCY_PATH

  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"; do
    model_file=mocha_${model}
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -w20 -r200 ${MODEL_ROOT}/${model_file} >${LOG_LATENCY_PATH}/${model_file}.log
    sleep 5
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} BACKENDS=${BACKENDS} RUY_THREADS=${RUY_THREADS} ${ADB_ONE_NNPKG_RUN_PATH} -m1 -w1 -r5 ${MODEL_ROOT}/${model_file} >${LOG_MEMORY_PATH}/${model_file}.log
    sleep 15
  done
}

model_load_warmup
# run
