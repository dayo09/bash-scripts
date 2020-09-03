#!/bin/bash
set -x
##############################################################################
################################ Settings ####################################

RUNTIME="tflite-vanilla-v2.3.0"
BINARY_TITLE=$1
BACKENDS=
MODEL="model_bcq_after_7.30"

SUBMODEL_LIST=("joint" "pred" "tran")
QUANT_LIST=("q" "f")

LOG_LATENCY=true
LOG_MEMORY=true

##############################################################################
##############################################################################
########################### Do not edit below ################################

## Generate Test List
MODEL_LIST=()
for m in ${SUBMODEL_LIST[@]}; do
  for q in ${QUANT_LIST[@]}; do
    MODEL_LIST+=(${m}${q})
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
echo "- Runtime : ${RUNTIME}" >>"${LOG_README}"
echo "- Binary : resource/${BINARY_TITLE}" >>"${LOG_README}"
echo "- Backend : - " >>"${LOG_README}"
echo "- Model : ${MODEL}" >>"${LOG_README}"
echo "  - Sub Models : ${SUBMODEL_LIST[@]}" >>"${LOG_README}"
echo "  - Quantizations : ${QUANT_LIST[@]}" >>"${LOG_README}"
echo "- Test Model List : ${MODEL_LIST[@]}" >>"${LOG_README}"
echo "- Log Enabled : Latency(${LOG_LATENCY}) Memory(${LOG_MEMORY})" >>"${LOG_README}"
echo "---------------------------------------------------------" >>"${LOG_README}"

## Set ADB Path to run & log
ADB_ROOT=/data/local/tmp
ADB_RUNTIME_PATH=$ADB_ROOT/${BINARY_TITLE}
ADB_RUNTIME_LIB_PATH=$ADB_RUNTIME_PATH/lib
ADB_RUNNER=$ADB_RUNTIME_PATH/bin/tflite_vanilla_run

MODEL_ROOT=${ADB_ROOT}/${MODEL}

if [ $LOG_LATENCY = true ]; then
  LOG_LATENCY_PATH=${LOG_PATH}/latency
  mkdir -p $LOG_LATENCY_PATH
fi

if [ $LOG_MEMORY = true ]; then
  LOG_MEMORY_PATH=${LOG_PATH}/memory
  mkdir -p $LOG_MEMORY_PATH
fi

LATENCY_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} ${ADB_RUNNER} -w20 -r200 --tflite " 
MEMORY_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} ${ADB_RUNNER} -m1 -r200 --tflite "
WARMUP_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} ${ADB_RUNNER} --tflite "

WarmUp() {
  for model in ${MODEL_LIST[@]}; do
    adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}/model.tflite"
  done
}

Run() {
  for model in ${MODEL_LIST[@]}; do
    adb shell "${LATENCY_RUN_COMMAND} ${MODEL_ROOT}/${model}/model.tflite" > ${LOG_LATENCY_PATH}/${model}.log
    sleep 5
    adb shell "${MEMORY_RUN_COMMAND} ${MODEL_ROOT}/${model}/model.tflite"  > ${LOG_MEMORY_PATH}/${model}.log
    sleep 15
  done

  adb shell "${LATENCY_RUN_COMMAND} ${MODEL_ROOT}/${MODEL_LIST[0]}/model.tflite" > ${LOG_LATENCY_PATH}/${model}_last.log
}

WarmUp
Run
set +x
