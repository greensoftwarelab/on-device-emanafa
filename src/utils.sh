#!/bin/bash

# Script: utils.sh
# Description: Contains utility functions used by other scripts.
# Author: Rui Rua
# Date: August 20, 2023

# Function: isOnDevice
# Description: Checks if the script is being run on an Android device via adb shell.
# Returns:
#   0 if the script is on a device, 1 if not
function isOnDevice(){
    check_command="getprop ro.build.version.sdk"
    # Run the command using adb shell
    result=$(adb shell "$check_command" 2> /dev/null)
    if [[ -n "$result" ]]; then
        echo 0
    else
        echo 1
    fi
}

# Function: getBootTime
# Description: Retrieves the system boot time from /proc/stat.
# Returns:
#   System boot time in seconds
function getBootTime(){
    prefix=""
    test $(isOnDevice) == "0" && prefix="adb shell" 
    echo $($prefix cat /proc/stat | grep btime | awk '{print $2}')
}

# Function: getCurrentTimestamp
# Description: Retrieves the current timestamp in seconds.
# Returns:
#   Current timestamp in seconds
function getCurrentTimestamp(){ 
    echo $(date +%s)
}
