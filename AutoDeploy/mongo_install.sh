#!/bin/bash
set -x
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
# ansible 执行脚本不能用相对路径
# source ./common_functions.sh
LOCAL_DATE=$(date +%F)

if [ ! -d /data/apps/mongo ];then
	down_software
	log_record  download
	mv $S_NAME $APP_DIR
fi


#openssl rand -base64 90 > ${SHELL_DIR}keyfiletest
#chmod 600 ${SHELL_DIR}keyfiletest

mkdir -p ${WORKSPACE_DIR}${S_NAME}/shard1

${APP_DIR}${S_NAME}/bin/mongod --dbpath ${WORKSPACE_DIR}${S_NAME}/shard1/ --logpath ${WORKSPACE_DIR}${S_NAME}/shard1/shard1.log --port 27011 --replSet repset --fork
log_record  started

#env
cp /etc/profile /etc/profile_$LOCAL_DATE
MONGODB_HOME_NUM=$(sed -n '/MONGODB_HOME/p' /etc/profile  |wc -l)
if [ $MONGODB_HOME_NUM == 0 ];then
PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
	if [ $PATH_NUM == 0 ];then
		echo "MONGODB_HOME=${APP_DIR}${S_NAME}"  >> /etc/profile
		echo "PATH=\$PATH:\$HOME/bin:\$MONGODB_HOME/bin"  >> /etc/profile
		echo "export PATH MONGODB_HOME" >>/etc/profile
	else
		sed -i '/^PATH=/i\MONGODB_HOME='${APP_DIR}''${S_NAME}'' /etc/profile
		sed -i '/^PATH\=\$/s/$/\:\$MONGODB_HOME\/bin/'  /etc/profile
		sed -i '/^export/s/$/ MONGODB_HOME/' /etc/profile
		
	fi
log_record  env
. /etc/profile

fi
#hosts
add_hosts
log_record create_hosts