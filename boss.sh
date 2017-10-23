#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/24"
#__time__="17:07"
SHELL_NAME=$(echo `basename $0`  |awk -F. '{print $1}')
log_record(){
LOCAL_DATE=$(date +%F\ %T)
if [ $? == 0 ];then
	echo ${LOCAL_DATE} $1 SUCESS >>/tmp/${SHELL_NAME}.log
else
	echo ${LOCAL_DATE} $1 FAILURE >>/tmp/${SHELL_NAME}.log
fi
}
