
# !/bin/bash

# Usage (on the device): nohup sh monkey_example.sh &

cd ..
sh manafa.sh start
monkey -p com.android.chrome -v 1000 --throttle 100 --ignore-crashes --ignore-security-exceptions  2> /dev/null
sh manafa.sh stop