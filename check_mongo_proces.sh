#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/28"
#__time__="9:42"

GET_HOSTNAME=$(echo "db.serverStatus()"| /data/mongodb/bin/mongo 127.0.0.1:27011 | grep  "host" | grep -v hosts |awk -F':' '{print $2}' |sed 's/"//' |sed 's/ //')
LOCAL_HOSTNAME=$(hostname)
if [ ${GET_HOSTNAME} == ${LOCAL_HOSTNAME} ];then
    echo OK -- mongodb proces OK
    exit 0
else
    echo WARNING -- mongodb proces is lost
    exit 2
fi