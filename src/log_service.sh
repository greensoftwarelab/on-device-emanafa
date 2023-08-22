#!/bin/bash

# Script: log_service.sh
# Description: Provides an interface to a service that manages Android device logs.
# Author: Rui Rua
# Date: August 20, 2023

# Usage: sh log_service.sh [command] [run_id]
# Commands:
#   install   Install the log management service on the device
#   export    Export log results from the device to local directory
#   init      Initialize the log management service
#   start     Start logging on the device
#   stop      Stop logging on the device and save logcat output
#   clean     Clean up log files on the device and local directory

# Dependencies: adb, isOnDevice (from utils.sh), getCurrentTimestamp (from utils.sh), getBootTime (from utils.sh)

# Global Variables:
#   PREFIX       - Command prefix based on whether the script is run on a device or not
#   RESULTS_DIR  - Directory where log files are stored on the device

source ./utils.sh

CMD=$1
RUN_ID=$2
PREFIX=""
IS_ON_DEVICE=$(isOnDevice)
RESULTS_DIR="/sdcard/manafa/results/logs"
test -z $1 && CMD=start
test -z $2 && test $CMD == "stop" && RUN_ID=$(getCurrentTimestamp)
test $IS_ON_DEVICE == "0" && PREFIX="adb shell "

# Function: install
# Description: Installs the log management service on the device.
function install(){
    $PREFIX mkdir -p $RESULTS_DIR
}

# Function: export_results
# Description: Exports log results from the device to the local directory.
function export_results(){
    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "Unable to export results from device."
        exit 3
    fi
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/logs
}

# Function: init
# Description: Initializes the log management service by performing cleanup.
function init(){
    clean
}

# Function: start
# Description: Starts logging on the device by performing cleanup.
function start(){
    clean
}

# Function: stop
# Description: Stops logging on the device, saves logcat output to a file.
function stop(){
    filename="hunter-$RUN_ID-$(getBootTime).log"
    echo "Log filename: $filename"
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        $PREFIX "logcat -d > $RESULTS_DIR/$filename"
    else
        $PREFIX logcat -d > "$RESULTS_DIR/$filename"
    fi
}

# Function: clean
# Description: Cleans up log files on the device and local directory.
function clean(){
    echo "Cleaning logs"
    $PREFIX logcat -c 
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} rm "{}" 2> /dev/null
}

$CMD
