#!/bin/bash

ADB_ROOT=/data/local/tmp/model_bcq

for i in "joint" "pred" "tran"
do
  MODEL_NAME3=bcq_${i}3
  MODEL_NAME5=bcq_${i}5
  MODEL_NAMEq=bcq_${i}q
  MODEL_NAMEf=bcq_${i}f
  adb shell ls -l ${ADB_ROOT}/${MODEL_NAME3}
  adb shell ls -l ${ADB_ROOT}/${MODEL_NAME5}
  adb shell ls -l ${ADB_ROOT}/${MODEL_NAMEq}
  adb shell ls -l ${ADB_ROOT}/${MODEL_NAMEf}
done
