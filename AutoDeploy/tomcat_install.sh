#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
down_software
mv $S_NAME $APP_DIR
log_record downlaod
TOMCAT_HOME_NUM=$(sed -n '/TOMCAT_HOME/p' /etc/profile  |wc -l)
if [ $TOMCAT_HOME_NUM == 0 ];then
  PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
  if [ $PATH_NUM == 0 ];then
    echo "TOMCAT_HOME=${APP_DIR}${S_NAME}" >>/etc/profile
    echo "PATH=\$PATH:\$HOME/bin:\$TOMCAT_HOME/bin"  >> /etc/profile
    echo "export PATH TOMCAT_HOME" >>/etc/profile
	log_record env
  else
    sed -i '/^PATH=/i\TOMCAT_HOME='${APP_DIR}''${S_NAME}'' /etc/profile
    sed -i '/^PATH\=\$/s/$/\:\$TOMCAT_HOME\/bin/' /etc/profile
    sed -i '/^export/s/$/ TOMCAT_HOME/' /etc/profile
	log_record env 
  fi
. /etc/profile
fi

#start
. /etc/profile
startup.sh