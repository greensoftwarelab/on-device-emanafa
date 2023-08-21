# !/bin/bash
source ./utils.sh

batteryStatsService="sh ./batterystats_service.sh"
perfettoService="sh ./perfetto_service.sh"
logService="sh ./log_service.sh"

CMD=$1
RUN_ID=$2
RESULTS_DIR="../results"
IS_ON_DEVICE=$(isOnDevice)
test -z $1 && CMD=start
test -z $2 && test "$1" == "stop" && RUN_ID=$(getCurrentTimestamp)

function export_results(){
    $perfettoService export_results
    $batteryStatsService export_results
    $logService export_results
}

function analyze(){
    #adb pull /system/framework/framework-res.apk $RESULTS_DIR
    emanafa -d $RESULTS_DIR

}

function install(){
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        push
    fi
    $perfettoService install
    $batteryStatsService install
    $logService install
}

function init(){
    $perfettoService init
    $batteryStatsService init
    $logService init
}

function start(){
    echo start
    $perfettoService start
    $batteryStatsService start
    $logService start
}

function stop(){
    $perfettoService stop "$RUN_ID"
    $batteryStatsService stop "$RUN_ID"
    $logService stop "$RUN_ID"
}

function clean(){
    echo cleaning
    $perfettoService clean
    $batteryStatsService clean
    $logService clean
}

function push(){
    adb shell mkdir -p /sdcard/manafa
    echo push
    adb push ../src /sdcard/manafa
}

function clean_local(){
    find $RESULTS_DIR -type f | xargs rm
}


$CMD
