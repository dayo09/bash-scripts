#!/bin/bash
set -x
##############################################################################
################################ Settings ####################################

GetConfig()
{
  return cat config.json | jq '.${$1}'
}

RUNTIME="one-v1.8.0"
BINARY_TITLE=v1.8.0-android-periannath-patch
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
echo "- Backend : ${BACKENDS}" >>"${LOG_README}"
echo "- Model : ${MODEL}" >>"${LOG_README}"
echo "  - Sub Models : ${SUBMODEL_LIST[@]}" >>"${LOG_README}"
echo "  - Quantizations : ${QUANT_LIST[@]}" >>"${LOG_README}"
echo "- Test Model List : ${MODEL_LIST[@]}" >>"${LOG_README}"
echo "- Log Enabled : Latency(${LOG_LATENCY}) Memory(${LOG_MEMORY})" >>"${LOG_README}"
echo "---------------------------------------------------------" >>"${LOG_README}"
echo "- RUY_THREADS : ${RUY_THREADS}" >>"${LOG_README}"
