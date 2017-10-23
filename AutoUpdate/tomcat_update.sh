#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/22"
#__time__="11:48"
WAR_NAME=api
SOFTWARE_DIR=/data/tools/
SHELL_DIR=/data/sh/
WAR_MD5_FILE="war_md5"
T_DAY=$(date +%Y%m%d)
.  /etc/profile
log_record(){
LOCAL_DATE=$(date +%F\ %T)
if [ $? == 0 ];then
	echo ${LOCAL_DATE} $1 SUCESS >>/tmp/tomcat_update.log
else
	echo ${LOCAL_DATE} $1 FAILURE >>/tmp/tomcat_update.log
fi
}

tomcat_pid() {
echo `ps -ef | grep ${TOMCAT_HOME} | grep -v grep | tr -s " "|cut -d" " -f2`
}

#下载war  校验war包完整性 拷贝war包到webapps目录下
down_software() {
	#下载压缩包，校验完整性并解压
	REMOTE_SOFTWARE_NAME=$(updateftp.sh find | grep ${T_DAY} | grep war)
	while :
	do
	cd ${SHELL_DIR} && updateftp.sh get -c ${WAR_MD5_FILE}
	cd ${SOFTWARE_DIR} && updateftp.sh  get -c ${REMOTE_SOFTWARE_NAME}
	SOFTWARE_MD5_VALUE=$(md5sum ${WAR_NAME}.war |awk '{print $1}')
	SOFTWARE_MD5_LIST_VALUE=$(cat ${SHELL_DIR}${WAR_MD5_FILE} |awk '/'${T_DAY}'/{print $1}')
	if [ $SOFTWARE_MD5_VALUE != $SOFTWARE_MD5_LIST_VALUE ];then
		ftp.sh  get -c $REMOTE_SOFTWARE_NAME

	else
		log_record download_war
		cd $SOFTWARE_DIR &&  cp ${WAR_NAME}.war ${TOMCAT_HOME}/webapps
		log_record copy_war
		break
	fi
	done
	}

#修改server.xml配置文件
CONTEXT_NUM=$(cat ${TOMCAT_HOME}/conf/server.xml |grep -c  "Context")
if [ ${CONTEXT_NUM} -eq 0 ];then
    sed -i '/unpackWARs/a\<Context path="/" docBase="caike" debug="0" privileged="true"/>' ${TOMCAT_HOME}/conf/server.xml
    log_record modify_server.xml
fi

#重启tomcat
pid=$(tomcat_pid)
if [ -n "$pid" ];then
	/etc/init.d/tomcat stop
	sleep 5
	/etc/init.d/tomcat start
else
	/etc/init.d/tomcat start
fi

log_record tomcat_restart