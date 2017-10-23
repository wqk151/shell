#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/26"
#__time__="17:30"

# 按时间段导入(分隔时间)：
# 定时任务 每天凌晨3点开始执行
# 导入所有库从前天00:00:00-23:59:59时间段的数据
# 首先要进行全库备份
# mongobackup 指定的起始和结束时间戳是CST时间(与UTC格式相差8小时)
START_DATE=$(date -d "`date -d "-1 day" +%F` 00:00:00" +%s)
STOP_DATE=$(date -d "`date -d "-1 day" +%F` 23:59:59" +%s)
TODAY=$(date +%F)
BACK_DIR=/data/backup/${TODAY}
DB_LIST=idcard

/data/apps/mongo2/bin/mongobackup --port 27012 -h 127.0.0.1 --recovery -s $START_DATE,1 -t $STOP_DATE,1  ${BACK_DIR}/backup

# 按库导入(分隔库)
# 定时任务每天凌晨4点执行
# 导入某库前天00:00:00-23:59:59时间段的数据
# 先进行全库备份导入

sleep 5
#  在mongo-log-01生产库上
# 按库导出--mongodump
/data/apps/mongo/bin/mongodump -h  127.0.0.1 --port 27012  -d  ${DB_LIST}  -o  ${BACK_DIR}

# 还原数据到log-mongodb
/data/apps/mongo/bin/mongorestore --port 27011 -d ${DB_LIST}  ${BACK_DIR}/${DB_LIST}

# 清空中转库的数据
sleep 5
echo `date +%F\ %H:%M:%S` >> /var/log/mongo/mongo-clear.log
cat /data/sh/clear_mongo_data.txt | /data/apps/mongo2/bin/mongo 127.0.0.1:27012 >> /var/log/mongo/mongo-clear.log