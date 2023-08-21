# !/bin/bash
source ./utils.sh

CMD=$1
RUN_ID=$2
PREFIX=""
WK_DIR=""
IS_ON_DEVICE=$(isOnDevice)
RESULTS_DIR="/sdcard/manafa/results/perfetto"
DEFAULT_OUT_DIR="/data/misc/perfetto-traces"
DEFAULT_OUTPUT_FILE="$DEFAULT_OUT_DIR/trace"
CONFIG_FILE="/sdcard/manafa/resources/perfetto.config.bin"

test -z $1 && CMD=start
test -z $2 && test $CMD == "stop" && RUN_ID=$(getCurrentTimestamp)
test $IS_ON_DEVICE == "0" && PREFIX="adb shell "
#test $IS_ON_DEVICE == "1" && WK_DIR=""

function install(){
    echo perfetto install
    echo "prefixo $PREFIX"
    $PREFIX mkdir -p $RESULTS_DIR
    test $IS_ON_DEVICE == "0" && adb push "resources/perfetto.config.bin" $CONFIG_FILE
}

function export_results(){
    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "unable to export results from device"
        exit 3
    fi
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/perfetto
}

function init(){
    echo perfetto init
    $PREFIX setprop persist.traced.enable 1
}

function start(){
    echo perfetto start
    #$PREFIX "cat $CONFIG_FILE | perfetto --background -o $DEFAULT_OUTPUT_FILE --config -"
    sh ./zaidu.sh $CONFIG_FILE $DEFAULT_OUTPUT_FILE
}

function stop(){
    echo perfetto stop
    $PREFIX killall perfetto
    sleep 1
    filename="trace-$RUN_ID-$(getBootTime)"
    echo "filename perfeito $filename"
    $PREFIX cp $DEFAULT_OUTPUT_FILE $RESULTS_DIR/$filename
}

function clean(){
    echo perfetto clean
    $PREFIX find $RESULTS_DIR  -type f | xargs -I {} rm "{}" 2> /dev/null
    $PREFIX killall perfetto
}



$CMD