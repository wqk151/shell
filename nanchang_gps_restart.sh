#!/bin/bash
set -x
set -e
#__date__=2016/11/7 0007 10:19

data_line_num=""
function get_data_line_num(){
        data_line_num=$(tail -n9  /data/log/datatangapi/pushapi-customer/nanchang/log/perf4j.log   | grep '[[:digit:]]$'  | grep -v Performance  |wc -l)
}
while :
do
get_data_line_num
#echo $data_line_num
if [ $data_line_num -lt 1 ];then
    /sbin/pwaiwang 192.168.2.1 -p 9289 -c 1  && ssh -p 22 192.168.1.1 "sh /data/sh/gps_nanchang.sh 1"
fi
sleep 60
done
