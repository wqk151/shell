#!/bin/bash
set -x
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
MONGO_PID=$(cat ${WORKSPACE_DIR}${S_NAME}/shard1/mongod.lock)
MONGO_NUM=$(ps aux | grep replSet |grep -v grep  |wc -l)
if [ $MONGO_NUM == 0 ];then
${APP_DIR}${S_NAME}/bin/mongod --keyFile  ${SHELL_DIR}keyfiletest --dbpath ${WORKSPACE_DIR}${S_NAME}/shard1/ --logpath ${WORKSPACE_DIR}${S_NAME}/shard1/shard1.log --port 27011 --replSet repset --fork
log_record mongo_restart
else
kill $MONGO_PID
#TODO初始没有数据，如果有数据关闭mongodb会比较慢，需要在修改脚本
sleep 10
${APP_DIR}${S_NAME}/bin/mongod --keyFile  ${SHELL_DIR}keyfiletest --dbpath ${WORKSPACE_DIR}${S_NAME}/shard1/ --logpath ${WORKSPACE_DIR}${S_NAME}/shard1/shard1.log --port 27011 --replSet repset --fork
log_record mongo_restart
fi