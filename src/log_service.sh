# !/bin/bash
source ./utils.sh

CMD=$1
RUN_ID=$2
PREFIX=""
WK_DIR=""
IS_ON_DEVICE=$(isOnDevice)
RESULTS_DIR="/sdcard/manafa/results/logs"
test -z $1 && CMD=start
test -z $2 && test $CMD == "stop" && RUN_ID=$(getCurrentTimestamp)
test $IS_ON_DEVICE == "0" && PREFIX="adb shell "

function install(){
    echo "logs install"
    $PREFIX mkdir -p $RESULTS_DIR
}

function export_results(){

    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "unable to export results from device"
        exit 3
    fi
   $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/logs
}

function init(){
    clean
}

function start(){
    clean
}

function stop(){
    filename="hunter-$RUN_ID-$(getBootTime).log"
    echo "filename log $filename"
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        $PREFIX "logcat -d > $RESULTS_DIR/$filename"
    else
        $PREFIX logcat -d > "$RESULTS_DIR/$filename"
    fi
}

function clean(){
    echo logs clean
    $PREFIX logcat -c 
    $PREFIX find $RESULTS_DIR  -type f | xargs -I {} rm "{}" 2> /dev/null
}

$CMD