#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/22"
#__time__="11:35"
#this is an infinite loop
while :
do
T_DAY=$(date +%Y%m%d)
UPDATE_DIR="/data/ftpdata/update"
WAR_DIR=${UPDATE_DIR}/${T_DAY}

# 检测目录及文件是否发生改变
du -ah --time  ${UPDATE_DIR} >/tmp/update_status
cd /tmp && md5sum update_status >>update_status_md5
VALUE1=$(tac /tmp/update_status_md5 |sed -n '1p'|awk '{print $1}')
VALUE2=$(tac /tmp/update_status_md5 |sed -n '2p'|awk '{print $1}')
# 如果目录或文件发生改变，则对当天目录下的war包生成md5文件
if [ ${VALUE1} != ${VALUE2} ];then
    if [ -d ${WAR_DIR} ];then
        for war in $(ls ${WAR_DIR})
        do
            m=$(md5sum ${WAR_DIR}/${war} )
            echo "$m ${T_DAY}">>${UPDATE_DIR}war_md5

        done
    fi

fi

sleep 60
done

