#!/bin/bash

# Script: perfetto_service.sh
# Description: Provides an interface to a service that manages Perfetto traces.
# Author: Rui Rua
# Date: August 20, 2023

# Usage: sh perfetto_service.sh [command] [run_id]
# Commands:
#   install   Install the Perfetto management service on the device
#   export    Export Perfetto trace results from the device to local directory
#   init      Initialize the Perfetto management service
#   start     Start capturing a Perfetto trace
#   stop      Stop capturing the Perfetto trace and save results
#   clean     Clean up Perfetto trace files on the device and local directory

# Dependencies: adb, isOnDevice (from utils.sh), getCurrentTimestamp (from utils.sh), getBootTime (from utils.sh)

# Global Variables:
#   PREFIX             - Command prefix based on whether the script is run on a device or not
#   RESULTS_DIR        - Directory where Perfetto trace files are stored on the device
#   DEFAULT_OUT_DIR    - Default directory for Perfetto trace output on the device
#   DEFAULT_OUTPUT_FILE - Default name for the Perfetto trace output file on the device
#   CONFIG_FILE        - Path to the Perfetto configuration file on the device

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

function install(){
    $PREFIX mkdir -p $RESULTS_DIR
    test $IS_ON_DEVICE == "0" && adb push "../resources/perfetto.config.bin" $CONFIG_FILE
}

function export_results(){
    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "Unable to export results from device."
        exit 3
    fi
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/perfetto
}

function init(){
    $PREFIX setprop persist.traced.enable 1
}

function start(){
    sh ./perfetto_service_aux.sh $CONFIG_FILE $DEFAULT_OUTPUT_FILE
}

function stop(){
    $PREFIX killall perfetto
    sleep 1
    filename="trace-$RUN_ID-$(getBootTime)"
    echo "Trace filename: $filename"
    $PREFIX cp $DEFAULT_OUTPUT_FILE $RESULTS_DIR/$filename
}

function clean(){
    $PREFIX find $RESULTS_DIR  -type f | xargs -I {} rm "{}" 2> /dev/null
    $PREFIX killall perfetto
}

$CMD
