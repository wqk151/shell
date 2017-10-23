#!/bin/bash
#set -x
sed -i '/^$/d' file 
NUM=`expr $(cat file |wc -l) / 2`
for ((i=1;i<=${NUM};i++))
do
sed -n '1p' file   >> file
HOST=$(sed -n '2p' file)

sed -i "\$s/$/ $HOST/" file
sed -i  '1,2d' file
sed -i 's/complete/  /' file
done

#先清除空行
#双引号里的特殊字符会转义
#单引号中的特殊字符不会转义

#一行解决：
sed ':a;$!N;/eth0$/s/\n/ /;ta;P;D' /tmp/hostslist |awk -F'/' '{print $1}' |awk '{print $8,$1}'>/tmp/hostslist
