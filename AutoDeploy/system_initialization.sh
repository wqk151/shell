#!/bin/bash
#系统初始化脚本
#修改时间:2016-04-28
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh

yum -y install libselinux-python net-snmp* git wget gcc gcc-c++ ftp lftp python-devel openssl-devel PyYAML  libyaml  vim zlib zlib-devel openssh-clients  ntpdate

echo "15 1 * * * /usr/sbin/ntpdate pool.ntp.org; hwclock -w >/dev/null 2>&1" > /var/spool/cron/root
\cp -f  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
/usr/sbin/ntpdate pool.ntp.org; hwclock -w >/dev/null 2>&1

/etc/init.d/iptables stop
chkconfig iptables off
/usr/sbin/setenforce 0
sed -i '7s/enforcing/disabled/' /etc/sysconfig/selinux

chmod +x /sbin/nmon && chmod +x /sbin/pwaiwang && chmod +x /bin/ftp.sh
chmod +x /data/sh/*.sh
chmod 600 /data/sh/keyfiletest

cat >>/etc/profile <<EOF
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S":
export HISTTIMEFORMAT 
EOF