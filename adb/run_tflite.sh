#!/bin/bash
set -x

TEST_NAME="tflite_benchmark_v2.3.0"

ADB_ROOT=/data/local/tmp
ADB_BENCHMARK="$ADB_ROOT/${TEST_NAME}/benchmark_model"

MODEL_ROOT=$ADB_ROOT/model_bcq

run_template() {
  LOG_PATH=~/nfs/bash_script/log/${TEST_NAME}/rnn-t/
  mkdir -p $LOG_PATH

  for model in "joint" "pred" "tran"; do
    for quant in "q" "f"; do
      model_file=${MODEL_ROOT}/bcq_${model}${quant}/${model}.tflite
      adb shell ${ADB_BENCHMARK} --num_threads=1 --warmup_runs=20 --num_runs=200 --graph=${model_file} > ${LOG_PATH}/bcq_${model}${quant}.log
      sleep 15
    done
  done

  LOG_PATH=~/nfs/bash_script/log/${TEST_NAME}/mocha/
  mkdir -p $LOG_PATH
  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"
  do
    model_file=mocha_${model}/${model}.tflite
    adb shell ${ADB_BENCHMARK} --num_threads=1 --warmup_runs=20 --num_runs=200 --graph=${model_file} > ${LOG_PATH}/mocha_${model}.log
    sleep 15
  done

}

run() {
  LOG_PATH=~/nfs/bash_script/log/${TEST_NAME}/mocha/
  mkdir -p $LOG_PATH
  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"
  do
    model_file=${MODEL_ROOT}/mocha_${model}/${model}.tflite
    adb shell ${ADB_BENCHMARK} --num_threads=1 --warmup_runs=20 --num_runs=200 --graph=${model_file} > ${LOG_PATH}/mocha_${model}.log
    sleep 15
  done
}

warmup(){
  for model in "enc" "enc1" "enc2" "dec1" "dec2" "dec3"
  do
    model_file=${MODEL_ROOT}/mocha_${model}/${model}.tflite
    adb shell ${ADB_BENCHMARK} --num_threads=1 --warmup_runs=20 --num_runs=200 --graph=${model_file}
  done
}

warmup
run
