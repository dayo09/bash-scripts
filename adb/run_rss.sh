## Generate Log Directory & Readme
BINARY_TITLE=$1
DATE="$(date +%Y-%m-%d_%T)"
LOG_TITLE=${BINARY_TITLE}/${DATE}
LOG_PATH=~/nfs/bash_script/log/${LOG_TITLE}/rss
LOG_README="${LOG_PATH}/README.md"

LOG_PATH_TF=${LOG_PATH}/tflite_vanilla_run
LOG_PATH_NN=${LOG_PATH}/nnpackage_run

prepareTarget(){
  adb shell mkdir /data/local/tmp/script/
  adb push ~/nfs/bash_script/resource/script/rss_measure.sh /data/local/tmp/script/
  ./adb/push_one.sh ${BINARY_TITLE}
}

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

makeReadme() {
  mkdir -p ${LOG_PATH}
  mkdir -p ${LOG_PATH_TF}
  mkdir -p ${LOG_PATH_NN}

  [[ -e "${LOG_README}" ]] && echo "Log directory ${LOG_PATH} is not empty." && exit 1

  touch "${LOG_README}"
  echo "- Date : ${DATE}" >>"${LOG_README}"
  echo "- Target : ${TARGET}" >>"${LOG_README}"
  echo "- Runtime : ${RUNTIME}" >>"${LOG_README}"
  echo "- Binary : resource/${BINARY_TITLE}" >>"${LOG_README}"
  echo "- Model : ${MODEL}" >>"${LOG_README}"
}

SUBMODEL_LIST=("joint" "pred" "tran")
QUANT_LIST=("3" "4" "q" "f")
MODEL_LIST=()
for m in ${SUBMODEL_LIST[@]}; do
  for q in ${QUANT_LIST[@]}; do
    MODEL_LIST+=(${m}${q})
  done
done

runTflite() {
  for MODEL in ${MODEL_LIST[@]}; do
    RUN_OPTIONS="-m1 -r200"
    TFLITE_RUN="export LD_LIBRARY_PATH=/data/local/tmp/${BINARY_TITLE}/lib && export BACKENDS=cpu && export RUY_THREADS=1 && sh /data/local/tmp/script/rss_measure.sh \" /data/local/tmp/v1.8.0-android-rss-sampler-patch2/bin/tflite_vanilla_run ${RUN_OPTIONS} --tflite /data/local/tmp/model_bcq_after_7.30/${MODEL}/model.tflite \" "
    TFLITE_WARMUP="export LD_LIBRARY_PATH=/data/local/tmp/${BINARY_TITLE}/lib && export BACKENDS=cpu && export RUY_THREADS=1 && sh /data/local/tmp/script/rss_measure.sh \" /data/local/tmp/v1.8.0-android-rss-sampler-patch2/bin/tflite_vanilla_run -r20 --tflite /data/local/tmp/model_bcq_after_7.30/${MODEL}/model.tflite \" "

    adb shell "${TFLITE_WARMUP}" >>${LOG_PATH_TF}/warmup.log
    adb shell "${TFLITE_WARMUP}" >>${LOG_PATH_TF}/warmup.log
    adb shell "${TFLITE_RUN}" >>${LOG_PATH_TF}/${MODEL}.log
  done
}

runOne() {
  for MODEL in ${MODEL_LIST[@]}; do
    RUN_OPTIONS="-m1 -r200"
    ONE_RUN_BIN="/data/local/tmp/${BINARY_TITLE}/bin/nnpackage_run"
    ONE_RUN_LIB="/data/local/tmp/${BINARY_TITLE}/lib"

    EXPORT_OPTIONS="export BACKENDS=\"cpu;bcq\" && RUY_THREADS=1"
    NNPACKAGE_RUN="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} ${RUN_OPTIONS} --nnpackage /data/local/tmp/model_bcq_after_7.30/${MODEL} \" "
    NNPACKAGE_WARMUP="export LD_LIBRARY_PATH=${ONE_RUN_LIB} && ${EXPORT_OPTIONS} && export RUY_THREADS=1 && sh /data/local/tmp/script/rss_measure.sh \" ${ONE_RUN_BIN} -r20 --nnpackage /data/local/tmp/model_bcq_after_7.30/${MODEL} \" "

    adb shell "${NNPACKAGE_WARMUP}" >>${LOG_PATH_NN}/warmup.log
    adb shell "${NNPACKAGE_WARMUP}" >>${LOG_PATH_NN}/warmup.log
    adb shell "${NNPACKAGE_RUN}" >>${LOG_PATH_NN}/${MODEL}.log
    #adb shell "" >> ${MODEL}.log
  done
}

echo "askTarget"
askTarget
echo "makeReadme"
makeReadme

echo "runOne" && runOne

#echo "runTflite" && runTflite

#echo "log2excel_rss, tf"
#python3 parser/log2excel_rss.py "${LOG_PATH_TF}"
#echo "log2excel_rss, nn"
#python3 parser/log2excel_rss.py "${LOG_PATH_NN}"
