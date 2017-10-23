#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/28"
#__time__="9:50"
MONGODB_STATUS=$(echo "rs.status()" | /data/mongodb/bin/mongo 127.0.0.1:27011  | grep stateStr | awk -F'"' '{print $4}')
# grep -o 精确匹配
PRIMARY_NUM=$(echo ${MONGODB_STATUS} |grep -o "PRIMARY" |wc -l)
SECONDARY_NUM=$(echo ${MONGODB_STATUS} |grep -o "SECONDARY" |wc -l)

if [ ${PRIMARY_NUM} -eq 1 -a ${SECONDARY_NUM} -eq 2 ];then
    echo "OK -- mongodb副本集正常"
    exit 0
else
    echo "WARNING -- mongodb副本集故障"
    exit 2
fi