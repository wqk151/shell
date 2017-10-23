#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/24"
#__time__="16:52"
#zookeeper cluster --> danshbord -->codis server -->start proxy-->online proxy-->codis-ha
# 加入开机启动,加入到rc.local或者/etc/init.d/目录下(注意添加一行：#chkconfig: 2345 80 90)
. /etc/profile
SHELL_NAME=$(echo `basename $0`  |awk -F. '{print $1}')
CODIS_DIR=/data/apps/codis/src/github.com/CodisLabs/codis
CODIS_CLIENT_DIR=/data/apps/codis/src/github.com/CodisLabs/codis/extern/redis-2.8.21/src

log_record(){
LOCAL_DATE=$(date +%F\ %T)
if [ $? == 0 ];then
	echo ${LOCAL_DATE} $1 SUCESS >>/tmp/${SHELL_NAME}.log
else
	echo ${LOCAL_DATE} $1 FAILURE >>/tmp/${SHELL_NAME}.log
fi
}
zk_start() {
ZK_NUM=$(ps -ef | grep zookeeper  | grep -v grep   |wc -l)
if [ ${ZK_NUM} -eg 0 ];then
    zkServer.sh start
    log_record zookeeper_start
fi
}
start_codis_dashboard(){
DASHBOARD_NUM=$(ps aux | grep dashboard  | grep -v grep |wc -l)
if [ ${DASHBOARD_NUM} -eq 0 ];then
    nohup ${CODIS_DIR}/bin/codis-config -c config.ini  -L ${CODIS_DIR}/log/dashboard.log  dashboard --addr=:18087 --http-log=${CODIS_DIR}/log/requests.log 2>&1 >/dev/null &
    log_record dashboard
fi
}

start_codis_server(){
CODIS_6379_NUM=$(ps aux | grep "codis-server" | grep -v grep | grep 6379|wc -l)
CODIS_6380_NUM=$(ps aux | grep "codis-server" | grep -v grep | grep 6380|wc -l)
if [ ${CODIS_6379_NUM} -eq 0 ];then
    ${CODIS_DIR}/bin/codis-server ./extern/redis-2.8.21/redis6379.conf
    log_record redis6379
fi
if [ ${CODIS_6380_NUM} -eq 0 ];then
    ${CODIS_DIR}/bin/codis-server ./extern/redis-2.8.21/redis6380.conf
    log_record redis6380
fi
}

start_codis_proxy(){
CODIS_PROXY_NUM=$( ps aux | grep "codis-proxy" | grep -v grep  | wc -l)
if [ ${CODIS_PROXY_NUM} -eq 0 ];then
    nohup ${CODIS_DIR}/bin/codis-proxy -c config.ini -L ${CODIS_DIR}/log/proxy$1.log  --cpu=2 --addr=0.0.0.0:9000 --http-addr=0.0.0.0:10000 &
    log_record codis_proxy_start
    sleep 5
    ${CODIS_DIR}/bin/codis-config -c config.ini proxy online proxy_$1
    log_record codis_proxy_online
fi

}

start_codis_ha(){
CODIS_HA_NMU=$(ps aux | grep "codis-ha" | grep -v grep  | wc -l)
if [ ${CODIS_HA_NMU} -eq 0 ];then
    nohup ${CODIS_DIR}/bin/codis-ha --codis-config=REDIS1:18087 --productName=codis > ${CODIS_DIR}/log/ha.log 2>&1 &
    log_record codis_ha
fi

}

while :
do
zk_start
sleep 5
zkServer.sh status >/tmp/1.txt
ZK_STATUS=$(cat /tmp/1.txt|grep Mode)
if [ ${ZK_STATUS} -eq 0 ];then
    zk_start
else
    start_codis_dashboard
    start_codis_server
    start_codis_proxy 1
    start_codis_ha
fi

# 在启动codis_proxy的服务器上验证,验证成功 退出循环
cd ${CODIS_CLIENT_DIR}
REDIS_VERSION=$(echo "info" | ./redis-cli -p 9000 | grep redis_version |awk -F":" '{print $2}')
if [[ ${REDIS_VERSION} == 2.8.21* ]];then
    exit
fi
sleep 5
done
