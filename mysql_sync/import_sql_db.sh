#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/20"
#__time__="10:47"
SQL_BACKUP_DIR=/data/binlog
LOCAL_DATE=$(date +%F)
DATABASE_BACKUP=object

if [ -f ${SQL_BACKUP_DIR}/${LOCAL_DATE}.sql ];then
mysql < ${SQL_BACKUP_DIR}/${LOCAL_DATE}.sql
fi

if [ -f ${SQL_BACKUP_DIR}/${LOCAL_DATE}2.sql ];then
mysql < ${SQL_BACKUP_DIR}/${LOCAL_DATE}2.sql
fi