#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/27"
#__time__="17:26"
set -x
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
HOST_LISTS=$(cat /tmp/hostslist  | awk '{print $2}')

i=1
# openssl rand -base64 90 > ${SHELL_DIR}keyfiletest
# chmod 600 ${SHELL_DIR}keyfiletest
echo "config = { _id:\"repset\", members:[ {_id:0,host:\"HOST1:27011\"}, {_id:1,host:\"HOST2:27011\"},{_id:2,host:\"HOST3:27011\"}]}" >/tmp/mongoinitconfig.txt

for h in $HOST_LISTS
do
	sed -i 's/HOST'$i'/'$h'/' /tmp/mongoinitconfig.txt
	# scp ${SHELL_DIR}keyfiletest "$h":/data/sh
	((i+=1))
done

#创建初始化副本集命令文件
echo "rs.initiate(config);" >>/tmp/mongoinitconfig.txt
echo "rs.status()" >/tmp/mongostatus.txt
cat > /tmp/mongocreateuser.txt <<EOF
db.createUser( {
user: "crowdadmin",
pwd: "2015_zaixianSimple",
roles:[ "clusterAdmin","userAdminAnyDatabase","dbAdminAnyDatabase","readWriteAnyDatabase" ] } )
EOF

#创建用户
for H in $HOST_LISTS
do
 /sbin/pwaiwang $H -p 27011 -c 1
 if [ $? == 0 ];then
	cat /tmp/mongoinitconfig.txt  | ${APP_DIR}${S_NAME}/bin/mongo ${H}:27011/admin
	log_record initiate
	sleep 5
	IP_PORT=$(cat /tmp/mongostatus.txt | ${APP_DIR}${S_NAME}/bin/mongo "${H}":27011 |grep -B 3 'PRIMARY' | awk -F'"' '/name/{print $4}')
	cat  /tmp/mongocreateuser.txt| ${APP_DIR}${S_NAME}/bin/mongo ${IP_PORT}/admin
	log_record createUser
	exit
 fi
done

