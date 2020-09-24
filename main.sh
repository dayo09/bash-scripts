#!/bin/bash

TEST_NAME=v1.10.0-original

#./adb/push_one.sh ${TEST_NAME}
./adb/run_one.sh ${TEST_NAME}
#./adb/run_tflite_vanilla.sh ${TEST_NAME}
python3 parser/log2excel.py ${TEST_NAME}
