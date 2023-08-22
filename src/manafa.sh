#!/bin/bash

# Script: manafa.sh
# Description: Provides an interface to manage the lifecycle of the inner services: battery stats, Perfetto, and log management.
# Author: Rui Rua
# Date: August 20, 2023

# Usage: sh ./manafa.sh [command] [run_id]
# Commands:
#   install       Install all managed services on the device
#   export        Export results from all managed services
#   init          Initialize all managed services
#   start         Start all managed services
#   stop          Stop all managed services
#   clean         Clean up all managed services
#   push          Push necessary files to the device
#   clean_local   Clean up local result files

# Dependencies: adb, isOnDevice (from utils.sh), getCurrentTimestamp (from utils.sh), emanafa (external tool)

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

# Function: export_results
# Description: Export results from all managed services
function export_results(){
    $perfettoService export_results
    $batteryStatsService export_results
    $logService export_results
}

# Function: analyze
# Description: Analyze exported results using emanafa python tool
function analyze(){
    emanafa -d $RESULTS_DIR
}

# Function: install
# Description: Install all managed services on the device
function install(){
    if [[ "$IS_ON_DEVICE" == "0" ]]; then
        push
    fi
    $perfettoService install
    $batteryStatsService install
    $logService install
}

# Function: init
# Description: Initialize all managed services
function init(){
    $perfettoService init
    $batteryStatsService init
    $logService init
}

# Function: start
# Description: Start all managed services
function start(){
    $perfettoService start
    $batteryStatsService start
    $logService start
}

# Function: stop
# Description: Stop all managed services
function stop(){
    $perfettoService stop "$RUN_ID"
    $batteryStatsService stop "$RUN_ID"
    $logService stop "$RUN_ID"
}

# Function: clean
# Description: Clean up all managed services
function clean(){
    $perfettoService clean
    $batteryStatsService clean
    $logService clean
}

# Function: push
# Description: Push necessary files to the device
function push(){
    adb shell mkdir -p /sdcard/manafa/results
    adb push ../src /sdcard/manafa
}

# Function: clean_local
# Description: Clean up local result files
function clean_local(){
    find $RESULTS_DIR -type f | xargs rm
}

$CMD
