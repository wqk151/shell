#!/usr/bin/bash
#__date__="2017-05-03"
#__time__="9:58"
set -e
set -x
data_line_num=""
function get_data_line_num(){
        data_line_num=$(tail -n9 /data/log/datatangapi/pushapi-customer/beijingImporTexi/perf4j.log   | grep '[[:digit:]]$'  | grep -v Performance  |wc -l)
}
while :
do
get_data_line_num
#echo $data_line_num
if [ $data_line_num -lt 1 ];then
    echo "data is empty"
    ssh -p 22 192.168.1.1 "sh /data/sh/beijingImpoTexi2Kafka.sh 2"
    sleep 60 # wait 60s
    get_data_line_num
    if [ $data_line_num -lt 1 ];then
        echo "data also is empty please wait 10min"
        ssh -p 22 192.168.1.1 "sh /data/sh/beijingImpoTexi2Kafka.sh 600"
     fi

fi
sleep 60
done
