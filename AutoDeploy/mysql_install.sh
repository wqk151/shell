#!/bin/bash
#从远处下载软件包到本地
#然后开始安装，并记录安装日志
#注意修改脚本存放路径变量:SCRIPT_DIR

SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
#MYSQL_INSTALL_DIR_TEMPNAME=$(echo $MYSQL_INSTALL_DIR|sed 's#\/#\\\/#g')
#编译安装配置mysql5.6
#修改时间:2016-04-28
#update 2016-05-25

#install software
yum -y install  gcc gcc-c++ gcc-g77 autoconf automake zlib* fiex* libxml* ncurses-devel libtool-ltdl-devel* make cmake library  bison-devel
#make user and group
groupadd mysql
useradd -s /sbin/nologin -g mysql -M mysql
#mkdir
mysql_dir_create

#down extract install
down_software

cd ${SOFTWARE_DIR}$S_NAME
mysql_cmake_option
log_record cmake

make && make install
log_record make_install


mv /etc/my.cnf /tmp/my.cnf-bak

#Initialize database
${MYSQL_INSTALL_DIR}/scripts/mysql_install_db  --datadir=${MYSQL_DATA_DIR} --user=mysql --basedir=${MYSQL_INSTALL_DIR}
log_record  initialize

chown -R mysql:mysql /data/apps/mysql/
# add service and start mysql with system on
cp ${MYSQL_INSTALL_DIR}/support-files/mysql.server /etc/init.d/mysql
cp ${MYSQL_INSTALL_DIR}/bin/mysql /bin/
sed -i "/\[mysqld\]/a\datadir="${MYSQL_DATA_DIR}"" ${MYSQL_INSTALL_DIR}/my.cnf
sed -i "/\[mysqld\]/a\log_error="${MYSQL_INSTALL_DIR}"/logs/error.log" ${MYSQL_INSTALL_DIR}/my.cnf
# sed -i "/\[mysqld\]/a\socket = "${SOFTWARE_DIR}${S_NAME}"/mysql.sock"   ${MYSQL_INSTALL_DIR}/my.cnf
chkconfig mysql on
/etc/init.d/mysql start
log_record start

#configure environment variable
echo "${LOG_DIR}/"$S_NAME"_install.log" | grep -q ERROR
if [ $? -ne 0 ];then
  cp /etc/profile /etc/profile_$LOCAL_DATE
  PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
  if [ $PATH_NUM == 0 ];then
    echo "MYSQL_HOME=${MYSQL_INSTALL_DIR}"  >> /etc/profile
    echo 'PATH=$PATH:$MYSQL_HOME/bin'  >>/etc/profile
  else
    sed -i '/^PATH=/i\MYSQL_HOME='${MYSQL_INSTALL_DIR}'' /etc/profile
    sed -i '/^PATH\=\$/s#$#:$MYSQL_HOME/bin#'  /etc/profile

  fi
  source /etc/profile
fi
