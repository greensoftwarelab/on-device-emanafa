# !/bin/bash

source ./utils.sh

CMD=$1
PREFIX=""
WK_DIR=""
RUN_ID=$2
IS_ON_DEVICE=$(isOnDevice)
RESULTS_DIR="/sdcard/manafa/results/batterystats"
test -z $1 && CMD=start
test -z $2 && test $CMD=="stop" && RUN_ID=$(getCurrentTimestamp)
test $IS_ON_DEVICE == "0" && PREFIX="adb shell "


function install(){
    echo batstat install
    $PREFIX mkdir -p $RESULTS_DIR
}

function export_results(){
    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "unable to export results from device"
        exit 3
    fi
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/batterystats
}

function init(){
    echo batstat init
}

function start(){
    echo batstat start
    $PREFIX dumpsys batterystats --reset
}

function stop(){
    echo batstat stop
    filename="bstats-$RUN_ID-$(getBootTime).log"
    #echo "$PREFIX dumpsys batterystats --history > $RESULTS_DIR/$filename"
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        $PREFIX "dumpsys batterystats --history > $RESULTS_DIR/$filename"
    else
        $PREFIX dumpsys batterystats --history > "$RESULTS_DIR/$filename"
    fi
}

function clean(){
    echo batstat clean
    $PREFIX find $RESULTS_DIR  -type f | xargs -I {} rm "{}" 2> /dev/null
}



$CMD