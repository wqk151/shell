#!/bin/bash
set -x
#tail -f /data/log/datatangapi/pushapi-customer/chongqingsuomeis/perf4j.log
#tail -f /data/log/datatangapi/pushapi-customer/chongqingsuomei/perf4j.log
#tail -f /data/log/datatangapi/pushapi-customer/beijingImporTexi/perf4j.log
#tail -f /data/log/datatangapi/pushapi-customer/nanchang/logt/perf4j.log
###
#nohup java -jar /opt/workspace/jar/v2/datatangapi-pushapi-receive-udp.jar >/dev/null &
#nohup java -jar /opt/workspace/jar/v2/beijingImpoTexi2Kafka.jar >/dev/null &
#nohup java -jar /opt/workspace/jar/nanchang/gps_nanchang.jar >/dev/null &

#########
case_dir(){
case "$1" in
    chongqingsuomeis)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh/datatangapi-pushapi-receive-udp.sh >/dev/null 2>&1 &"
        ;;
     chongqingsuomei)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh/datatangapi-pushapi-receive-udp.sh>/dev/null 2>&1 &"
        ;;
    beijingImporTexi)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh/beijingImpoTexi2Kafka.sh >/dev/null 2>&1 &"
        ;;
    nanchang/log)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh/gps_nanchang.sh >/dev/null 2>&1 &"
        ;;
esac
}

case2_dir(){
case "$1" in
    chongqingsuomeis)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh600/datatangapi-pushapi-receive-udp.sh >/dev/null 2>&1 &"
        ;;
     chongqingsuomei)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh600/datatangapi-pushapi-receive-udp.sh>/dev/null 2>&1 &"
        ;;
    beijingImporTexi)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh600/beijingImpoTexi2Kafka.sh >/dev/null 2>&1 &"
        ;;
    nanchang/log)
         ssh -p 52523 api-datatang.chinacloudapp.cn "nohup sh /data/sh600/gps_nanchang.sh >/dev/null 2>&1 &"
        ;;
esac
}


log_record(){
LOCAL_DATE=$(date +%F\ %T)
  echo $LOCAL_DATE $1  $2 >>/tmp/bj.log
}
DIR_LISTS="chongqingsuomeis chongqingsuomei beijingImporTexi nanchang/log"

while :
do
    for d in $DIR_LISTS
    do
    COUNT_NUM=$(tail -n3  /data/log/datatangapi/pushapi-customer/"$d"/perf4j.log |awk '{print $NF}' |grep -E '^[0-9]+$'|wc -l)
        if [ $COUNT_NUM -eq 0 ]> /dev/null 2>&1
        then
            case_dir ${d}
            log_record ${d} 60
            sleep 60
            COUNT_NUM=$(tail -n3  /data/log/datatangapi/pushapi-customer/"$d"/perf4j.log |awk '{print $NF}'|grep -E '^[0-9]+$'|wc -l)
            if [ $COUNT_NUM -eq 0 ]> /dev/null 2>&1
            then
            case2_dir ${d}
            log_record ${d} 600
            fi
         fi
    done
sleep 600
done