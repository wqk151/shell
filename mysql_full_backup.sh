#!/bin/bash
set -x
set -e
#__date__=2016/11/2 0002 11:34

mysql_backup_dir='/data/mysql_backup'
mysql_backup_time=$(date +%Y%m%d)
mysql_backup_begintime=$(date +%Y%m%d%H%M)
mysqldump -uroot -p123456 api | gzip >$mysql_backup_dir/apifull${mysql_backup_time}.sql.gz
mysql_backup_endtime=$(date +%Y%m%d%H%M)
echo "begin:$mysql_backup_begintime end:$mysql_backup_endtime success"  >>/tmp/mysql_full_backup.log
find $mysql_backup_dir -name "*.sql.gz" -mtime +7 -exec rm {} \; >/dev/null 2>&1

# 解压缩：gunzip apifull20161102.sql.gz