#!/bin/bash

##############################################################################
################################ Settings ####################################

RUNTIME="one"
BINARY_TITLE=$1
BACKENDS="cpu"
MODEL="model_bcq_after_7.30"

SUBMODEL_LIST=("joint" "pred" "tran")
#SUBMODEL_LIST=("joint")
QUANT_LIST=("3" "4" "q" "f")
#QUANT_LIST=("q")

LOG_LATENCY=true
LOG_MEMORY=true

RUY_THREADS=1

##############################################################################
##############################################################################
########################### Do not edit below ################################

# Target : Exynos or Snapdragon
askTarget() {
  read -p "Target? Exynos(e/E) or Snapdragon(s/S)" choice
  case "$choice" in
  e | E)
    TARGET="Exynos"
    ;;
  s | S)
    TARGET="Snapdragon"
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

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
echo "- Target : ${TARGET}" >>"${LOG_README}"
echo "- Runtime : ${RUNTIME}" >>"${LOG_README}"
echo "- Binary : resource/${BINARY_TITLE}" >>"${LOG_README}"
echo "- Backend : ${BACKENDS}" >>"${LOG_README}"
echo "- Model : ${MODEL}" >>"${LOG_README}"
echo "  - Sub Models : ${SUBMODEL_LIST[@]}" >>"${LOG_README}"
echo "  - Quantizations : ${QUANT_LIST[@]}" >>"${LOG_README}"
echo "- Test Model List : ${MODEL_LIST[@]}" >>"${LOG_README}"
echo "- Log Enabled : Latency(${LOG_LATENCY}) Memory(${LOG_MEMORY}) Memory/Rss(${LOG_MEMORY_RSS})" >>"${LOG_README}"
echo "---------------------------------------------------------" >>"${LOG_README}"
echo "- RUY_THREADS : ${RUY_THREADS}" >>"${LOG_README}"

## Set ADB Path to run & log
ADB_ROOT=/data/local/tmp
ADB_RUNTIME_PATH=$ADB_ROOT/${BINARY_TITLE}
ADB_RUNTIME_LIB_PATH=$ADB_RUNTIME_PATH/lib
ADB_RUNNER=$ADB_RUNTIME_PATH/bin/nnpackage_run

MODEL_ROOT=${ADB_ROOT}/${MODEL}

if [ $LOG_LATENCY = true ]; then
  LOG_LATENCY_PATH=${LOG_PATH}/latency
  mkdir -p $LOG_LATENCY_PATH
fi

if [ $LOG_MEMORY = true ]; then
  LOG_MEMORY_PATH=${LOG_PATH}/memory
  mkdir -p $LOG_MEMORY_PATH
fi

if [ $LOG_MEMORY_RSS = true ]; then
  LOG_MEMORY_RSS_PATH=${LOG_PATH}/memory/rss
  mkdir -p $LOG_MEMORY_RSS_PATH
fi

LATENCY_RUN_ARGS="-w20 -r200"
MEMORY_RUN_ARGS="-m1 -r200"
RSS_RUN_ARGS="??"

LATENCY_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} ${LATENCY_RUN_ARGS} "
MEMORY_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} ${MEMORY_RUN_ARGS} "
WARMUP_RUN_COMMAND="LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} "

WarmUp() {
  for model in ${MODEL_LIST[@]}; do
    adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"
  done
}

RunAndLog() {
  echo "$1 : $2" >> ${LOG_README}
  adb shell "$2"
}

RunLatency() {
  for model in ${MODEL_LIST[@]}; do
    RunAndLog "Warmup" "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"

    #echo "Warmup : ${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}" >> ${LOG_README}
    #adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"

    #echo "Run(Latency) : ${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model} >${LOG_LATENCY_PATH}/${model}.log " >> ${LOG_README}
    #adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model}" >${LOG_LATENCY_PATH}/${model}.log

    #echo "sleep 5" >> ${LOG_README}
  done
    
  #echo "Last-to-First Compare : ${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]} > ${LOG_LATENCY_PATH}/${MODEL_LIST[0]}_last.log" >> ${LOG_README}
  #adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >${LOG_LATENCY_PATH}/${MODEL_LIST[0]}_last.log
}

RunMemory() {
  for model in ${MODEL_LIST[@]}; do
    echo "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model}" >> ${LOG_README}
    adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model}" >${LOG_LATENCY_PATH}/${model}.log
    echo "sleep 5" >> ${LOG_README}
    sleep 5
    echo "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model}" >> ${LOG_README}
    adb shell "${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${model}" >${LOG_MEMORY_PATH}/${model}.log
    echo "sleep 15" >> ${LOG_README}
    sleep 15
  done

  adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >${LOG_LATENCY_PATH}/${MODEL_LIST[0]}_last.log
}


RunRSS() {
  for model in ${MODEL_LIST[@]}; do
    RUN_OPTIONS="-r200"
    ONE_RUN_BIN="/data/local/tmp/${BINARY_TITLE}/bin/nnpackage_run"
    ONE_RUN_LIB="/data/local/tmp/${BINARY_TITLE}/lib"

    EXPORT_OPTIONS="export BACKENDS=\"cpu;bcq\" && RUY_THREADS=1"
    NNPACKAGE_RUN="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} ${RUN_OPTIONS} --nnpackage /data/local/tmp/model_bcq_after_7.30/${model} \" "
    NNPACKAGE_WARMUP="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && export RUY_THREADS=1 && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} -r20 --nnpackage /data/local/tmp/model_bcq_after_7.30/${model} \" "

    adb shell "${NNPACKAGE_WARMUP}" >>${LOG_MEMORY_RSS_PATH}/warmup.log
    adb shell "${NNPACKAGE_RUN}" >>${LOG_MEMORY_RSS_PATH}/${model}.log
  done
}

#RunRSS() {
#  adb shell "sh ${ADB_ROOT}/script/rss_measure.sh \"${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}\""
#}

#WarmUp
#Run
#RunRSS
RunLatency
