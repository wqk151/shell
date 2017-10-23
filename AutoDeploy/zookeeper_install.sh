#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
LOCAL_DATE=$(date +%F)
ID=3
LOCAL_IP=$(ifconfig  | grep "inet addr"  | grep -v "127.0.0.1"  |awk '{print $2}' |sed 's/.*\://')
LOCAL_HOSTNAME=$(sed -n '/'${LOCAL_IP}'/p' ${SHELL_DIR}hostslist | awk '{print $2}')
ZK_HOSTS_NAME=$(awk '{print $2}' ${SHELL_DIR}hostslist)


down_software
mv $S_NAME  $APP_DIR
log_record download

#修改配置文件
cd ${APP_DIR}${S_NAME}/conf && cp zoo_sample.cfg  zoo.cfg
mkdir ${WORKSPACE_DIR}zkdata
ZK_DATADIR_TEMPNAME=$(echo ${WORKSPACE_DIR}|sed 's#\/#\\\/#g')
sed -i '/dataDir=/s/=.*/='${ZK_DATADIR_TEMPNAME}'zkdata/' zoo.cfg
for h in $ZK_HOSTS_NAME
do
	sed -i '/dataDir=/a\server.'$ID'='$h':2888:3888' ${APP_DIR}${S_NAME}/conf/zoo.cfg
	if [ $h = $LOCAL_HOSTNAME ];then
		echo "$ID" >${WORKSPACE_DIR}zkdata/myid
	fi
	
	((ID-=1))
done
log_record zoo.cfg
#env configure
cp /etc/profile /etc/profile_$LOCAL_DATE
ZK_HOME_NUM=$(sed -n '/^ZK_HOME/p' /etc/profile  |wc -l)
if [ $ZK_HOME_NUM == 0 ];then
        PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
        if [ $PATH_NUM == 0 ];then
          echo "ZK_HOME=${APP_DIR}${S_NAME}"  >> /etc/profile
          echo "PATH=\$PATH:\$ZK_HOME/bin"  >> /etc/profile
          echo "export PATH ZK_HOME" >>/etc/profile
        else
          sed -i '/^PATH=/i\ZK_HOME='${APP_DIR}''${S_NAME}'' /etc/profile
          sed -i '/^PATH\=\$/s/$/\:\$ZK_HOME\/bin/' /etc/profile
          sed -i '/^export/s/$/ ZK_HOME/' /etc/profile
        fi
        . /etc/profile
fi
log_record env

#add hosts
add_hosts
log_record create_hosts

#start
. /etc/profile
zkServer.sh start
