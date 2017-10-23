#!/bin/bash
#设置FTP重试次数
######
#cat ~/.lftprc
#set net:max-retries 2
######
USER_NAME=update
USER_PASSWD=tgsdfa
FTP_SERVER_IP=10.10.8.136
#如果密码中有特殊字符，则需要转义。
#例如：lftp tools:adfan\@#\@1@10.10.8.136 << EOF
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