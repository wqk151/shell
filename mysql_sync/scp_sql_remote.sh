#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/19"
#__time__="10:56"
# import_binglog_db.log 记录上次读取到的binglog的位置，binlog名称及路径
# 第一次手动导入数据库并记录log和start_position位置
#1、最后一个事物是不执行的
#2、--start-position 要上移一个位置
#3、如果上移位置过多，会重复执行，数据会重复
BINLOG_BACKUP_DIR=/data/apps/mysql/mysqlinstall/logs
DATABASE_BACKUP=object
LOCAL_DATE=$(date +%F)
OLD_BINLOG=$(sed -n '2p' ${BINLOG_BACKUP_DIR}/import_binlog_db.log|awk -F'/' '{print $NF}')
START_POSITION=$(sed -n '1p' ${BINLOG_BACKUP_DIR}/import_binlog_db.log)
POSITION_LISTS=$(mysqlbinlog ${BINLOG_BACKUP_DIR}/${OLD_BINLOG} |sed -n '/^# at [0-9].*/p' |tac|awk '{print $NF}' |tr '\n' ' ')
POSITION_ARR=($POSITION_LISTS)
STOP_POSITION=${POSITION_ARR[0]}
NEXT_START_POSITION=${POSITION_ARR[1]}

NEWEST_BINLOG=$(ls ${BINLOG_BACKUP_DIR} | grep ^binlog | grep -v index |tail -n 1)
if [ "${OLD_BINLOG}" == "${NEWEST_BINLOG}" ];then
    if [ $START_POSITION != $NEXT_START_POSITION ];then
        /data/apps/mysql/mysqlinstall/bin/mysqlbinlog --start-position=${START_POSITION} --stop-position=${STOP_POSITION}  --database=${DATABASE_BACKUP} ${BINLOG_BACKUP_DIR}/${OLD_BINLOG} --result-file=${LOCAL_DATE}.sql
        sed -i 's/'${START_POSITION}'/'${NEXT_START_POSITION}'/' ${BINLOG_BACKUP_DIR}/import_binlog_db.log
        scp ${LOCAL_DATE}*  192.168.1.1:/tmp
    fi
else

   NEW_POSITION_LISTS=$(mysqlbinlog ${BINLOG_BACKUP_DIR}/${NEWEST_BINLOG} |sed -n '/^# at [0-9].*/p' |tac|awk '{print $NF}' |tr '\n' ' ')
   NEW_POSITION_ARR=($NEW_POSITION_LISTS)
   NEW_STOP_POSITION=${NEW_POSITION_ARR[0]}
   NEW_NEXT_START_POSITION=${NEW_POSITION_ARR[1]}
    if [ $START_POSITION != $NEXT_START_POSITION ];then
        /data/apps/mysql/mysqlinstall/bin/mysqlbinlog --start-position=${START_POSITION} --stop-position=${STOP_POSITION}  --database=${DATABASE_BACKUP} ${BINLOG_BACKUP_DIR}/${OLD_BINLOG} --result-file=${LOCAL_DATE}.sql
    fi
    sleep 2
    /data/apps/mysql/mysqlinstall/bin/mysqlbinlog --start-position=4 --stop-position=${NEW_STOP_POSITION}  --database=${DATABASE_BACKUP} ${BINLOG_BACKUP_DIR}/${NEWEST_BINLOG} --result-file=${LOCAL_DATE}2.sql
    if [ ${#NEW_POSITION_ARR[@]} != 1 ];then
        sed -i 's/'${START_POSITION}'/'${NEW_NEXT_START_POSITION}'/' ${BINLOG_BACKUP_DIR}/import_binlog_db.log
        sed -i '2d' ${BINLOG_BACKUP_DIR}/import_binlog_db.log
        echo "${BINLOG_BACKUP_DIR}/${NEWEST_BINLOG}" >>${BINLOG_BACKUP_DIR}/import_binlog_db.log
    else
        sed -i 's/'${START_POSITION}'/4/' ${BINLOG_BACKUP_DIR}/import_binlog_db.log
        sed -i '2d' ${BINLOG_BACKUP_DIR}/import_binlog_db.log
        echo "${BINLOG_BACKUP_DIR}/${NEWEST_BINLOG}" >>${BINLOG_BACKUP_DIR}/import_binlog_db.log
    fi
    scp ${LOCAL_DATE}*  192.168.1.1:/tmp

fi

