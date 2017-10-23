#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/22"
#__time__="14:28"
USER_NAME=update
USER_PASSWD=tgYN6RIB
FTP_SERVER_IP=10.10.8.136
#如果密码中有特殊字符，则需要转义。
#例如：lftp tools:Admin\@#\@1@10.10.8.136 << EOF
a=`echo $1`
if [ ! -n "$a" ];then
echo "参数错误"
else
lftp ${USER_NAME}:${USER_PASSWD}@$FTP_SERVER_IP << EOF
$1 $2 $3 $4 $5 $6
exit
EOF
fi
exit 0