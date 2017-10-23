#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
down_software
mv $S_NAME $APP_DIR
log_record download
chmod 777 -R ${APP_DIR}${S_NAME}

JAVA_HOME_NUM=$(sed -n '/^JAVA_HOME/p' /etc/profile  |wc -l )
if [ $JAVA_HOME_NUM == 0 ];then
PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
if [ $PATH_NUM == 0 ];then
  echo "JAVA_HOME=${APP_DIR}${S_NAME}"  >> /etc/profile
  echo "CLASSPATH=${APP_DIR}${S_NAME}/lib"  >> /etc/profile
  echo "PATH=\$PATH:\$JAVA_HOME/bin"  >> /etc/profile
  echo "export PATH JAVA_HOME CLASSPATH" >>/etc/profile
  log_record env
else
  sed -i '/^PATH=/i\JAVA_HOME='${APP_DIR}''${S_NAME}'' /etc/profile
  sed -i '/^PATH=/i\CLASSPATH='${APP_DIR}''${S_NAME}'/lib' /etc/profile
  sed -i '/^PATH\=\$/s/$/\:\$JAVA_HOME\/bin/'  /etc/profile
  sed -i '/^export/s/$/ JAVA_HOME CLASSPATH/' /etc/profile
  log_record env
fi
. /etc/profile
fi