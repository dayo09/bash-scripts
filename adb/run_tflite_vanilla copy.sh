#!/bin/bash
set -x

LOG_TITLE=android-v1.8.0-one-patch2
ADB_TITLE=one_v1.8.0_patch2

ADB_ROOT=/data/local/tmp
ADB_ONE_PATH=$ADB_ROOT/${ADB_TITLE}
ADB_ONE_LIB_PATH=$ADB_ONE_PATH/lib
ADB_TFLITE_RUN="$ADB_ONE_PATH/bin/tflite_vanilla_run"

MODEL_ROOT=$ADB_ROOT/model_bcq

run_template() {

  # 1. RNN-T
  LOG_MEMORY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/rnn-t/tflite/memory
  LOG_LATENCY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/rnn-t/tflite/latency
  mkdir -p $LOG_MEMORY_PATH
  mkdir -p $LOG_LATENCY_PATH

  for model in "joint" "pred" "tran"; do
    for quant in "q" "q_v2.2.0" "f"; do
      model_file=${MODEL_ROOT}/bcq_${model}${quant}/${model}.tflite
      adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w1 -r5 -m1 --tflite ${model_file} >${LOG_MEMORY_PATH}/bcq_${model}${quant}.log
      sleep 5
      adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w20 -r100 --tflite ${model_file} >${LOG_LATENCY_PATH}/bcq_${model}${quant}.log
      sleep 10
    done
  done

  # 2. Mocha
  LOG_MEMORY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/mocha/tflite/memory
  LOG_LATENCY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/mocha/tflite/latency
  mkdir -p $LOG_MEMORY_PATH
  mkdir -p $LOG_LATENCY_PATH

  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"; do
    model_file=mocha_${model}/${model}.tflite
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w1 -r5 -m1 --tflite ${MODEL_ROOT}/${model_file} > ${LOG_MEMORY_PATH}/mocha_${model}.log
    sleep 5
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w20 -r100 --tflite ${MODEL_ROOT}/${model_file} > ${LOG_LATENCY_PATH}/mocha_${model}.log
    sleep 10
  done
}

run()
{

  # 2. Mocha
  LOG_MEMORY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/mocha/tflite/memory
  LOG_LATENCY_PATH=~/nfs/bash_script/log/${LOG_TITLE}/mocha/tflite/latency
  mkdir -p $LOG_MEMORY_PATH
  mkdir -p $LOG_LATENCY_PATH

  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"; do
    model_file=mocha_${model}/${model}.tflite
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w1 -r5 -m1 --tflite ${MODEL_ROOT}/${model_file} > ${LOG_MEMORY_PATH}/mocha_${model}.log
    sleep 5
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -w20 -r100 --tflite ${MODEL_ROOT}/${model_file}  > ${LOG_LATENCY_PATH}/mocha_${model}.log
    sleep 10
  done
}

warmup()
{
  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"; do
    model_file=mocha_${model}/${model}.tflite
    adb shell LD_LIBRARY_PATH=${ADB_ONE_LIB_PATH} ${ADB_TFLITE_RUN} -r1 --tflite ${MODEL_ROOT}/${model_file} 
  done
}
#run_template
warmup
run
