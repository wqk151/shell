#!/bin/bash
KAILIDE_LOG_DIR="/data/log/datatangapi/pushapi-customer/kailide"
log_record(){
LOCAL_DATE=$(date +%F\ %T)
  echo $LOCAL_DATE bj_rev_restart >>/tmp/bj.log
}
while :
COUNT_NUM=$(tail -n 4 ${KAILIDE_LOG_DIR}/perf4j.log |sed '/^$/d' |awk '{print $NF}'|grep -E '^[0-9]+$'|wc -l)
do
    if [ $COUNT_NUM -eq 0 ]> /dev/null 2>&1
    then
        ssh -p 52523 api-datatang.chinacloudapp.cn "sh /data/sh/bj_rev_restart.sh"
	log_record
        sleep 60
        COUNT_NUM=$(tail -n 4 ${KAILIDE_LOG_DIR}/perf4j.log |sed '/^$/d' |awk '{print $NF}'|grep -E '^[0-9]+$'|wc -l)
        if [ $COUNT_NUM -eq 0 ]> /dev/null 2>&1
        then
        sleep 600
        ssh -p 52523 api-datatang.chinacloudapp.cn "sh /data/sh/bj_rev_restart.sh"
	log_record
        fi

    fi
sleep 60
done