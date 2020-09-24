#!/bin/bash

cd /home/dayo/nfs/ONE

LOG_DIR_NAME="odroid-memory-v1.7.0-patch-transform-manager-release2"
LOG_DIR_PATH=/home/dayo/nfs/bash_script/log/$LOG_DIR_NAME
mkdir -p $LOG_DIR_PATH

for model_name in "joint3" "pred3" "tran3" "joint5" "pred5" "tran5"
do
BACKENDS="cpu" ./Product/armv7l-linux.release/out/bin/nnpackage_run -w1 -r10 -m1 --nnpackage ../model_bcq/bcq_${model_name} > ${LOG_DIR_PATH}/${model_name}.log
done
