#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/26"
#__time__="17:28"
# 备份：定时任务--每天凌晨2:00开始备份
# 拷贝mongobackup 到mongodb的bin目录下后，需要重启mongodb
START_DATE=$(date -d "`date -d "-1 day" +%F` 00:00:00" +%s)
TODAY=$(date +%F)
BACK_DIR=/data/backup/${TODAY}
# 按天生成目录
mkdir -p ${BACK_DIR}
# 从前天00:00:00 为备份起点，到当前时间
cd ${BACK_DIR} && /data/apps/mongo/bin/mongobackup --port 27011 -h 127.0.0.1 --backup -s ${START_DATE},1
sleep 3
# 拷贝到远程中转mongodb副本集
scp -r  ${BACK_DIR}  ${中转mongodb ip }:/data/backup