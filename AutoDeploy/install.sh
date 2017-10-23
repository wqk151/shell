#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/27"
#__time__="17:21"
set -x
#主程序---是否初始化系统----根据$2 调用相关函数---对$1进行批量分发
#注意修改脚本存放路径变量:SCRIPT_DIR
SCRIPT_DIR=$(pwd)
GS_NUM=$(cat ${SCRIPT_DIR}/common_functions.sh | grep -C 3 bash | grep S_NAME |wc -l)

#添加判断 组名和应用名是否正确
APP_LISTS="mysql,tomcat,jdk,go,zookeeper,expect,nagios,mongo,lvs,redis,keeplived,codis,nrpe"
GROUP_LISTS=$(cat /etc/ansible/hosts  | grep "\[.*\]" |sed -e 's/\[//' -e 's/\]//' -e 's/:.*//')
#安装tomcat和zookeeper提醒安装jdk

if [ $# -ne 3 ];then
    print_usage
    exit
fi
#判断groupname appname是否正确
echo "$GROUP_LISTS" | grep -q "$1"
if [ $? -eq 0 ];then
	echo "$APP_LISTS" | grep -q "$2"
	if [ $? -ne 0 ];then
		echo -e "warning - can not fand the app name \033[31m$2\033[0m you inputed in the app lists ..."
		print_usage
		exit
	fi
else
	echo -e "warning - can not fand the group name \033[31m$1\033[0m you inputed in the file /etc/ansible/hosts ..."
	print_usage
	exit
fi

#将groupname 和appname 传入common_functions.sh文件
if [ $GS_NUM == 0 ];then
	sed -i '/bash/a\G_NAME='$1'' ${SCRIPT_DIR}/common_functions.sh
	sed -i '/bash/a\S_NAME='$2'' ${SCRIPT_DIR}/common_functions.sh
else
	sed -i '2s/=.*/='$2'/' ${SCRIPT_DIR}/common_functions.sh
	sed -i '3s/=.*/='$1'/' ${SCRIPT_DIR}/common_functions.sh
fi

source ${SCRIPT_DIR}/common_functions.sh
create_hosts_list
while :
do
#echo -n "do you want to init the system y|n: "
#read choise
#判断是否需要初始化系统
	if [ $3 == 1 ];then
		echo -e "\033[32be going to install gcc gcc-c ... and stop iptables time-syn ...and so on\033[0m"
		ansible-playbook ${SCRIPT_DIR}/copy_file_remote.yml -e "group_name=$1"
		ansible-playbook ${SCRIPT_DIR}/copy_scripts_remote.yml -e "group_name=$1 app_script="$2"_install.sh"
		ansible  $1  -m script -a "${SCRIPT_DIR}/system_initialization.sh"

		break
	elif [ $3 == 2 ];then
		echo -e "be going to skip system init and going to install \033[4;31m$2\033[0m please waiting..."
		ansible-playbook ${SCRIPT_DIR}/copy_scripts_remote.yml -e "group_name=$1 app_script="$2"_install.sh"
		break
	else
		echo "input error,please re enter..."

	fi
done

#判断参数个数是否等于3
if [ $# -eq 3 ];then
ansible  $1  -m script -a "${SCRIPT_DIR}/"$2"_install.sh"
	if [ $2 = 'mongo' ];then
		sh mongo_init_screat.sh
		ansible  $1  -m script -a "${SCRIPT_DIR}/mongo_restart.sh"
	fi
else
print_usage
fi

