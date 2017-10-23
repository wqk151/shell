#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/28"
#__time__="16:17"
HOST_TEMPLATE=apiyunying-host
SERVICE_TEMPLATE=apiyunying-service
FILE=/usr/local/nagios/etc/objects/AliYun-API-Service.cnf
cat >>${FILE}<<EOF
define hostgroup{
        hostgroup_name  ${FILE_NAME} ; The name of the hostgroup
        alias           ${FILE_NAME} ; Long name of the group
        members
}
EOF
FILE_NAME=$(echo $FILE |awk -F/ '{print $NF}')
source /data/sh/Service_common.sh
cat nagios_file |while read line
do
HNAME=`echo $line |awk '{print $1}'|tr '[A-Z]' '[a-z]'`
IP=`echo $line |awk '{print $2}'`
SSH_PORT=`echo $line |awk '{print $3}'`
NAGIOS_PORT=`echo $line |awk '{print $4}'`
SER_NUM=`echo $line |awk '{print $5}'|sed 's/-/ /g'`

if [ -n "${SER_NUM}" ];then
sed -i '/members/s/$/\,'$HNAME'/' ${FILE}
echo "#####-${HNAME}-#####" >>${FILE}
add_host_service
    for n in ${SER_NUM}
    do
        if [ $n == '1' ];then
            add_mysql_service
        elif [ $n == '2' ];then
            add_mysql_sync_service
        elif [ $n == '3' ];then
            add_mongo_service
        elif [ $n == '4' ];then
            add_mongo_replica_service
        elif [ $n == '5' ];then
            add_tomcat_service
        fi
    done
else
    continue
fi
done

sed -i '/members/s/members,/members /' ${FILE}
echo "cfg_file=${FILE}" >> /usr/local/nagios/etc/nagios.cfg