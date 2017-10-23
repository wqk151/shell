#!/bin/bash
set -x
#定义变量
SOFTWARE_DIR=/data/tools/
APP_DIR=/data/apps/
WORKSPACE_DIR=/data/workspace/
SHELL_DIR=/data/sh/
LOG_DIR=/tmp
NAGIOS_HOSTNAME="op-vm-001.chinacloudapp.cn"

log_record(){
	#安装日志记录,调用函数，如果有与函数中重名的变量，会改变变量的值
  if [ $? == 0 ];then
    LOG_REC_TIME=$(date +%F\ %T)
    echo OK - $LOCAL_DATE  $G_NAME:$S_NAME $1 Ok !! >>${LOG_DIR}/"$S_NAME"_install.log
  else
  	LOG_REC_TIME=$(date +%F\ %T)
    echo ERROR - $LOCAL_DATE  $G_NAME:$S_NAME $1 error!! >>${LOG_DIR}/"$S_NAME"_install.log
  fi
LOG_OK_NUM=$(cat ${LOG_DIR}/"$S_NAME"_install.log | wc -l)
}


print_usage() {
	#帮助
	echo "Usage: install.sh [groupname] [appname]"
	echo -e  "\033[34meg: ./install.sh webs tomcat\033[0m"
	echo ""
	echo "groupname:"
	echo -e "\033[34mplease get groupname use the file /etc/ansible/hosts\033[0m"
	echo ""
	echo "appname:"
	echo -e "\033[32mmysql\033[0m"
	echo -e "\033[32mgo\033[0m"
	echo -e "\033[32mjdk\033[0m"
	echo -e "\033[32mexpect\033[0m"
	echo -e "\033[32mnagios\033[0m"
	echo -e "\033[32mmongo\033[0m"
	echo -e "\033[32mredis\033[0m"
	echo -e "\033[32mlvs\033[0m"
	echo -e "\033[32mzookeeper\033[0m"
	echo -e "\033[32mtomcat\033[0m"

}

print_help() {
	print_usage
}

mysql_cmake_option() {
	#mysql编译安装cmake选项
cmake \
-DMYSQL_USER=mysql \
-DCMAKE_INSTALL_PREFIX=/data/apps/mysql/mysqlinstall \
-DMYSQL_DATADIR=/data/apps/mysql/mysqldata \
-DMYSQL_UNIX_ADDR=/data/apps/mysql/mysql.sock \
-DSYSCONFDIR=/data/apps/mysql/ \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_READLINE=1
}
mysql_dir_create() {
	#创建mysql相关目录
	MYSQL_INSTALL_DIR=${APP_DIR}mysql/mysqlinstall
	MYSQL_DATA_DIR=${APP_DIR}mysql/mysqldata
	mkdir -p $MYSQL_INSTALL_DIR
	mkdir -p $MYSQL_DATA_DIR
	mkdir -p $MYSQL_INSTALL_DIR/logs
}

down_software() {
	#下载压缩包，校验完整性并解压
	REMOTE_SOFTWARE_NAME=$(ftp.sh find | grep "\<${S_NAME}.*.gz")
	while :
	do
	cd $SOFTWARE_DIR && ftp.sh  get -c $REMOTE_SOFTWARE_NAME
	SOFTWARE_MD5_VALUE=$(md5sum ${S_NAME}.tar.gz |awk '/\<'${S_NAME}'/{print $1}')
	SOFTWARE_MD5_LIST_VALUE=$(cat ${SHELL_DIR}md5sum_file |awk '/\<'${S_NAME}'/{print $1}')
	if [ $SOFTWARE_MD5_VALUE != $SOFTWARE_MD5_LIST_VALUE ];then
		ftp.sh  get -c $REMOTE_SOFTWARE_NAME

	else
		cd $SOFTWARE_DIR &&  tar zxf ${S_NAME}.tar.gz
		break
	fi
	done
	}
create_hosts_list() {
	#创建一个 IP+hostname 的对应关系表
	ansible ${G_NAME} -m shell -a 'ip a | grep -v 127 | grep global' >/tmp/hostslist
	sed -i '/^$/d' /tmp/hostslist
	L=`sed ':a;$!N;/eth0$/s/\n/ /;ta;P;D' /tmp/hostslist |awk -F'/' '{print $1}' |awk '{print $8,$1}'`
	# -e表示启用解释反斜杠转义 默认为-E：禁用转义
	echo -e "$L ">/tmp/hostslist
	#HOST_NUM=$(cat /tmp/hostslist | grep inet | wc -l)
	#for ((i=1;i<=${HOST_NUM};i++))
	#do
	#sed -n '2p' /tmp/hostslist |awk '{print $2}' |sed 's/\/.*//'  >> /tmp/hostslist
	#HOST=$(sed -n '1p' /tmp/hostslist |awk '{print $1}')

	#sed -i "\$s/$/ "$HOST"/" /tmp/hostslist
	#sed -i  '1,2d' /tmp/hostslist
	#done
}
confirm_hosts_reachable(){
	#判断远程主机是否可达
	ansible $G_NAME  -m 'ping' >$LOG_DIR/ansible_ping.log
	HOSTS_NUM=$(cat $LOG_DIR/ansible_ping.log|grep "=>" |wc -l)
	HOSTS_SUCESS_NUM=$(cat $LOG_DIR/ansible_ping.log|grep "SUCCESS" |wc -l)
	HOSTS_UNREACHABLE_NAME=$(cat $LOG_DIR/ansible_ping.log|awk '/UNREACHABLE/{print $1}')
	if [ $HOSTS_SUCESS_NUM != $HOSTS_NUM ];then
		echo "can not connect hosts $HOSTS_UNREACHABLE_NAME !!please check again"
		exit
	else
		break
	fi

}

add_hosts() {
	#配置hosts文件
for HOST_NAME in $(cat ${SHELL_DIR}hostslist | awk '{print $2}')
do
  HOST_NAME_NUM=$(sed -n '/'$HOST_NAME'/p' /etc/hosts  |wc -l)
  if [ $HOST_NAME_NUM = 0 ];then
    cat ${SHELL_DIR}hostslist | grep "$HOST_NAME"  >>/etc/hosts
  fi
done

}