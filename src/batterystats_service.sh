#!/bin/bash

# Script: batterystats_service.sh
# Description: Provides an interface to a service that manages Android battery statistics (batterystats).
# Author: Rui Rua
# Date: August 20, 2023

# Usage: sh batterystats_service.sh [command] [run_id]
# Commands:
#   install   Install the battery stats management service on the device
#   export    Export battery stats results from the device to local directory
#   init      Initialize the battery stats management service
#   start     Start tracking battery statistics
#   stop      Stop tracking battery statistics and save results
#   clean     Clean up battery stats files on the device and local directory

# Dependencies: adb, isOnDevice (from utils.sh), getCurrentTimestamp (from utils.sh), getBootTime (from utils.sh)

# Global Variables:
#   PREFIX       - Command prefix based on whether the script is run on a device or not
#   RESULTS_DIR  - Directory where battery stats files are stored on the device

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

# Function: install
# Description: Installs the battery stats management service on the device.
function install(){
    $PREFIX mkdir -p $RESULTS_DIR
}

# Function: export_results
# Description: Exports battery stats results from the device to the local directory.
function export_results(){
    if [[ "$IS_ON_DEVICE" != "0" ]]; then
        echo "Unable to export results from device."
        exit 3
    fi
    $PREFIX find $RESULTS_DIR -type f | xargs -I {} adb pull "{}" ../results/batterystats
}

# Function: init
# Description: Initializes the battery stats management service.
function init(){
    echo ""
}

# Function: start
# Description: Resets battery statistics.
function start(){
    $PREFIX dumpsys batterystats --reset
}

# Function: stop
# Description: Saves  battery statistics.
function stop(){
    filename="bstats-$RUN_ID-$(getBootTime).log"
    echo "Batterystats filename: $filename"
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        $PREFIX "dumpsys batterystats --history > $RESULTS_DIR/$filename"
    else
        $PREFIX dumpsys batterystats --history > "$RESULTS_DIR/$filename"
    fi
}

# Function: clean
# Description: Cleans up battery stats files on the device and local directory.
function clean(){
    $PREFIX find $RESULTS_DIR  -type f | xargs -I {} rm "{}" 2> /dev/null
}

$CMD
