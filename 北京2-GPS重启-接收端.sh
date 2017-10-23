#!/usr/bin/bash
#__date__="2017-05-03"
#__time__="10:07"
set -e
set -x

restart_gps_time=`date +%F\ %H:%M:%S`
SCRIPT_NAME=$(basename $0|sed 's/\..*//')
BJ_REV_NUM=$(ps aux | grep "${SCRIPT_NAME}.jar"  | grep -v grep   |wc -l)
BJ_REV_PID=$(ps aux | grep "${SCRIPT_NAME}.jar"  | grep -v grep   | awk '{print $2}')
#echo $BJ_REV_PID
if [ $BJ_REV_NUM -ne 0 ] > /dev/null 2>&1
then
    kill $BJ_REV_PID
    echo "$restart_gps_time beijing2_gps will restart after $1">> /tmp/beijing2_gps_restart.log
    sleep $1
    nohup java -jar /opt/workspace/jar/v2/${SCRIPT_NAME}.jar >/dev/null &
    echo "$LOG_REC_TIME" >>/tmp/cq.log
else
    nohup java -jar /opt/workspace/jar/v2/${SCRIPT_NAME}.jar >/dev/null &
    echo "$LOG_REC_TIME" >>/tmp/cq.log
fi
