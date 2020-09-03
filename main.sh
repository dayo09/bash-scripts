#!/bin/bash

TEST_NAME=v1.9.0-one

./adb/push_one.sh ${TEST_NAME}
#./adb/run_one.sh ${TEST_NAME}
#./adb/run_tflite_vanilla.sh ${TEST_NAME}
#python3 parser/log2excel.py v1.9.0-one 2020-09-02_18:36:11
