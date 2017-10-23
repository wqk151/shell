#!/bin/bash
set -x
set -e
#__date__=2016/11/2 0002 12:08

mysql_binlog_dir='/data/mysql/log'
mysql_backup_dir='/data/mysql_backup'
mysql_binlog_index_file='mysql-bin.index'
mysql_backup_time=$(date +%Y%m%d)
binlog_backup_dir=$mysql_backup_dir/$mysql_backup_time
mkdir -p $binlog_backup_dir # 按天生成备份目录

mysqladmin -uroot -p123456 flush-logs  # 用于产生新的binlog文件
if [ ! -s /tmp/binlog_num.log ]
then
    echo "0" >/tmp/binlog_num.log
fi
oldnum=$(cat /tmp/binlog_num.log)
newnum=$(cat  $mysql_binlog_dir/$mysql_binlog_index_file|wc -l)
echo $newnum > /tmp/binlog_num.log
need_backup_binlog_num=$(expr $newnum - $oldnum + 1)  # 判断有多少个新的binlog产生

for (( i=2;i<=$need_backup_binlog_num;i++ ))  # 循环拷贝新的binlog文件到当天的备份目录
do
    new_binlog=$(tac $mysql_binlog_dir/$mysql_binlog_index_file|sed -n ""$i"p" )
    if [ -n "$new_binlog" ];then   # 第一次oldnum=0，会多出一次循环，则new_binlog=None
        cp $new_binlog $binlog_backup_dir
     fi
done
#备注：增量备份脚本是备份前flush-logs,mysql会自动把内存中的日志放到文件里,然后生成一个新的日志文件,所以我们只需要备份前面的几个即可,也就是不备份最后一个.