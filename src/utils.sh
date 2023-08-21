# !/bin/bash


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

function getBootTime(){
    prefix=""
    test $(isOnDevice) == "0" && prefix="adb shell" 
    echo $($prefix cat /proc/stat | grep btime | awk '{print $2}')
}

function getCurrentTimestamp(){ 
    echo $(date +%s)
}
