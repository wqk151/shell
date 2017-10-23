#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/28"
#__time__="9:44"
FILE=/usr/local/nagios/etc/objects/AliYun-API-Hardware.cnf
FILE_NAME=$(echo $FILE |awk -F/ '{print $NF}')
cat >>${FILE}<<EOF
define hostgroup{
        hostgroup_name  ${FILE_NAME} ; The name of the hostgroup
        alias           ${FILE_NAME} ; Long name of the group
        members
}
EOF

cat nagios_file |while read line
do
HNAME=`echo $line |awk '{print $1}'`
IP=`echo $line |awk '{print $2}'`
SSH_PORT=`echo $line |awk '{print $3}'`
NAGIOS_PORT=`echo $line |awk '{print $4}'`
echo "#####-${HNAME}-#####" >>${FILE}
sed -i '/members/s/$/\,'$HNAME'/' ${FILE}

cat >> $FILE << EOF
define host{
        use                         apiyunying-host,hosts-pnp
        host_name                   ${HNAME}
        alias                       ${HNAME}
        address                     ${IP} -p ${NAGIOS_PORT}
}
define service{
        use                         apiyunying-service
        host_name                   ${HNAME}
        service_description         通过ssh判定机器存活
        check_command               check_ssh! -p ${SSH_PORT}
        max_check_attempts          3
        normal_check_interval       1
        retry_check_interval        1
        notifications_enabled       1
}
define service{
        use                         apiyunying-service
        host_name                   ${HNAME}
        service_description         CPU负载
        check_command               check_nrpe!check_load
        notifications_enabled       1
}
#表示监测远程主机的CPU负载。
#监测当前远程主机的僵死进程数

define service{
        use                             apiyunying-service
        host_name                       ${HNAME}
        service_description             僵尸进程
        check_command                   check_nrpe!check_zombie_procs
        notifications_enabled           1
}

define service{
        use                             apiyunying-service         ; Name of service template to use
        host_name                       ${HNAME}
        service_description             服务器/data分区状况
        check_command                   check_nrpe!check_disk
        #check_command                  check_local_disk!20%!10%!/
        }
define service{
        use                             apiyunying-service         ; Name of service template to use
        host_name                       ${HNAME}
        service_description             服务器根分区状况
        check_command                   check_nrpe!check_sda1
        }
#监测远程主机当前的登录用户数量，如果登录数量大于20用户则产生warning警告，如果大于50则产生critical警告：

define service{
        use                             apiyunying-service         ; Name of service template to use
        host_name                       ${HNAME}
        service_description             当前服务器用户登陆个数
        check_command                   check_nrpe!check_users
        }
#监测远程主机当前的进程总数，如果大于250进程则产生warning警告，如果大于400进程则产生critical警告：

define service{
        use                             apiyunying-service        ; Name of service template to use
        host_name                       ${HNAME}
        service_description             进程总数
        check_command                   check_nrpe!check_total_procs
        #check_command                  check_local_procs!250!400!RSZDT
        notifications_enabled           1
        }
#内存使用情况
define service{
      use                            apiyunying-service
      host_name                      ${HNAME}
      service_description            内存使用情况 Memory
      check_command                  check_nrpe!check_free_mem
      notifications_enabled          1
      }
#CPU使用率
define service{
      use                            apiyunying-service,srv-pnp
      host_name                      ${HNAME}
      service_description            CPU使用率
      check_command                  check_nrpe!check_cpu
      notifications_enabled          1
      }
#网卡流量状况
define service{
      use                            apiyunying-service
      host_name                      ${HNAME}
      service_description            网卡流量状况
      check_command                  check_nrpe!check_traffic
      notifications_enabled          1
      }
#磁盘I/O
define service{
      use                            apiyunying-service
      host_name                      ${HNAME}
      service_description            磁盘I/O状态 根分区
      check_command                  check_nrpe!check_I/O
      notifications_enabled          1
      }
EOF
done
sed -i '/members/s/members,/members /' ${FILE}
echo "cfg_file=${FILE}" >> /usr/local/nagios/etc/nagios.cfg