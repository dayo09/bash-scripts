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

BENCHMARK_WARMUP=true
BENCHMARK_LATENCY=true
BENCHMARK_MEMORY=true
BENCHMARK_MEMORY_SMAPS=true

RUY_THREADS=1

##############################################################################
##############################################################################
########################### Do not edit below ################################

askBenchmarkWarmup() {
  read -p "Benchmark Warmup? (y/Y | n/N)" choice
  case "$choice" in
  y | Y)
    BENCHMARK_WARMUP=true
    ;;
  n | N)
    BENCHMARK_WARMUP=false
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

askBenchmarkLatency() {
  read -p "Benchmark Latency? (y/Y | n/N)" choice
  case "$choice" in
  y | Y)
    BENCHMARK_LATENCY=true
    ;;
  n | N)
    BENCHMARK_LATENCY=false
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

askBenchmarkMemory() {
  read -p "Benchmark Memory? (y/Y | n/N)" choice
  case "$choice" in
  y | Y)
    BENCHMARK_MEMORY=true
    ;;
  n | N)
    BENCHMARK_MEMORY=false
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

askBenchmarkMemorySmaps() {
  read -p "Benchmark Memory Smaps? (y/Y | n/N)" choice
  case "$choice" in
  y | Y)
    BENCHMARK_MEMORY_SMAPS=true
    ;;
  n | N)
    BENCHMARK_MEMORY_SMAPS=false
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

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

  read -p "Target Binary? User(u/U) or Engineering(e/E)" choice
  case "$choice" in
  u | U)
    TARGET_BINARY="User Binary"
    ;;
  e | E)
    TARGET_BINARY="Engineering Binary"
    ;;
  *)
    echo "Invalid input. Exit."
    Exit 1
    ;;
  esac
}

askTarget
askBenchmarkLatency
askBenchmarkMemory
askBenchmarkMemorySmaps

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
echo "- Target Device : ${TARGET}" >>"${LOG_README}"
echo "- Target Device Binary : ${TARGET_BINARY}" >>"${LOG_README}"
echo "- Runtime : ${RUNTIME}" >>"${LOG_README}"
echo "- Binary : resource/${BINARY_TITLE}" >>"${LOG_README}"
echo "- Backend : ${BACKENDS}" >>"${LOG_README}"
echo "- Model : ${MODEL}" >>"${LOG_README}"
echo "  - Sub Models : ${SUBMODEL_LIST[@]}" >>"${LOG_README}"
echo "  - Quantizations : ${QUANT_LIST[@]}" >>"${LOG_README}"
echo "- Test Model List : ${MODEL_LIST[@]}" >>"${LOG_README}"
echo "- Benchmark Enabled : Warmup(${BENCHMARK_WARMUP}) Latency(${BENCHMARK_LATENCY}) Memory(${BENCHMARK_MEMORY}) Memory/SMAPS(${BENCHMARK_MEMORY_SMAPS})" >>"${LOG_README}"
echo "---------------------------------------------------------" >>"${LOG_README}"
echo "- RUY_THREADS : ${RUY_THREADS}" >>"${LOG_README}"

## Set ADB Path to run & log
ADB_ROOT=/data/local/tmp
ADB_RUNTIME_PATH=$ADB_ROOT/${BINARY_TITLE}
ADB_RUNTIME_LIB_PATH=$ADB_RUNTIME_PATH/lib
ADB_RUNNER=$ADB_RUNTIME_PATH/bin/nnpackage_run

MODEL_ROOT=${ADB_ROOT}/${MODEL}

if [ $BENCHMARK_LATENCY = true ]; then
  LOG_LATENCY_PATH=${LOG_PATH}/latency
  mkdir -p $LOG_LATENCY_PATH
fi

if [ $BENCHMARK_MEMORY = true ]; then
  LOG_MEMORY_PATH=${LOG_PATH}/memory
  mkdir -p $LOG_MEMORY_PATH
fi

if [ $BENCHMARK_MEMORY_SMAPS = true ]; then
  LOG_MEMORY_SMAPS_PATH=${LOG_PATH}/memory/smaps
  mkdir -p $LOG_MEMORY_SMAPS_PATH
fi

LATENCY_RUN_ARGS="-w20 -r200"
MEMORY_RUN_ARGS="-m1 -r200"
SMAPS_RUN_ARGS="??"

LATENCY_RUN_COMMAND="BACKENDS=\"cpu;bcq\" LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} ${LATENCY_RUN_ARGS} "
MEMORY_RUN_COMMAND="BACKENDS=\"cpu;bcq\" LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} ${MEMORY_RUN_ARGS} "
WARMUP_RUN_COMMAND="BACKENDS=\"cpu;bcq\" LD_LIBRARY_PATH=${ADB_RUNTIME_LIB_PATH} RUY_THREADS=${RUY_THREADS} ${ADB_RUNNER} "

WarmUp() {
  for model in ${MODEL_LIST[@]}; do
    adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"
  done
}

RunLatency() {
  echo "Last-to-First Compare (First) : ${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
  adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}

  for model in ${MODEL_LIST[@]}; do
    echo "Warmup : ${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}" >> ${LOG_README}
    adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"

    echo "Run(Latency) : ${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model} >${LOG_LATENCY_PATH}/${model}.log " >> ${LOG_README}
    adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${model}" >${LOG_LATENCY_PATH}/${model}.log

    echo "sleep 15" >> ${LOG_README}
    sleep 15
  done
    
  echo "Last-to-First Compare (Last) : ${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
  adb shell "${LATENCY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
}

RunMemory() {
  echo "Last-to-First Compare (First) : ${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
  adb shell "${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}

  for model in ${MODEL_LIST[@]}; do
    echo "Warmup : ${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}" >> ${LOG_README}
    adb shell "${WARMUP_RUN_COMMAND} ${MODEL_ROOT}/${model}"

    echo "Run(Memory) : ${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${model}" >> ${LOG_README}
    adb shell "${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${model}" >${LOG_MEMORY_PATH}/${model}.log

    echo "sleep 5" >> ${LOG_README}
    sleep 5
  done

  echo "Last-to-First Compare (Last) : ${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
  adb shell "${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}" >> ${LOG_README}
}

set -x
RunMemorySmaps() {
  for model in ${MODEL_LIST[@]}; do
    RUN_OPTIONS="-r200"
    ONE_RUN_BIN="/data/local/tmp/${BINARY_TITLE}/bin/nnpackage_run"
    ONE_RUN_LIB="/data/local/tmp/${BINARY_TITLE}/lib"

    EXPORT_OPTIONS="export BACKENDS=\"cpu;bcq\" && RUY_THREADS=1"
    NNPACKAGE_RUN="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} ${RUN_OPTIONS} --nnpackage /data/local/tmp/model_bcq_after_7.30/${model} \" "
    NNPACKAGE_WARMUP="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && export RUY_THREADS=1 && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} -r20 --nnpackage /data/local/tmp/model_bcq_after_7.30/${model} \" "

    adb shell "${NNPACKAGE_RUN}" > ${LOG_MEMORY_SMAPS_PATH}/${model}.log
  done
}

#RunSMAPS() {
#  adb shell "sh ${ADB_ROOT}/script/rss_measure.sh \"${MEMORY_RUN_COMMAND}${MODEL_ROOT}/${MODEL_LIST[0]}\""
#}

[[ $BENCHMARK_WARMUP = true ]] && WarmUp
[[ $BENCHMARK_LATENCY = true ]] && RunLatency
[[ $BENCHMARK_MEMORY = true ]] && RunMemory
[[ $BENCHMARK_MEMORY_SMAPS = true ]] && RunMemorySmaps
#RunMemory
#RunMemorySmaps
set +x
