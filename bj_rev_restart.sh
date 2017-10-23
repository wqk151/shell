#!/bin/bash
SCRIPT_NAME=$(basename $0|sed 's/\..*//')
BJ_REV_NUM=$(ps aux | grep "${SCRIPT_NAME}.jar"  | grep -v grep   |wc -l)
BJ_REV_PID=$(ps aux | grep "${SCRIPT_NAME}.jar"  | grep -v grep   | awk '{print $2}')
#echo $BJ_REV_PID
if [ $BJ_REV_NUM -ne 0 ] > /dev/null 2>&1
then
    kill $BJ_REV_PID
    sleep 10
    nohup java -jar /opt/workspace/jar/v2/${SCRIPT_NAME}.jar >/dev/null &
else
    nohup java -jar /opt/workspace/jar/v2/${SCRIPT_NAME}.jar >/dev/null &
fi