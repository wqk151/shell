#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/28"
#__time__="16:40"
add_host_service(){
cat >>${FILE}<<EOF
define host{
      use                           ${HOST_TEMPLATE}
      host_name                     ${HNAME}
      alias                         ${HNAME}
      address                       ${IP} -p ${NAGIOS_PORT}
}
EOF
}
add_mysql_service(){
cat >>${FILE}<<EOF
define service{
      use                            ${SERVICE_TEMPLATE}
      host_name                      ${HNAME}
      service_description            ${HNAME} mysql服务状态
      check_command                  check_nrpe!check_smysql
}
EOF
}
add_mysql_sync_service(){
cat >>${FILE}<<EOF
define service{
      use                            ${SERVICE_TEMPLATE}
      host_name                      ${HNAME}
      service_description            ${HNAME} mysql主从服务状态
      check_command                  check_nrpe!check_mysqlrsync
}
EOF
}
add_mongo_service(){
cat >>${FILE}<<EOF
define service{
      use                            ${SERVICE_TEMPLATE}
      host_name                      ${HNAME}
      service_description            ${HNAME} mongodb服务状态
      check_command                  check_nrpe!check_mongodb
}
EOF
}
add_mongo_replica_service(){
cat >>${FILE}<<EOF
define service{
      use                            ${SERVICE_TEMPLATE}
      host_name                      ${HNAME}
      service_description            ${HNAME} mongodb副本集状态
      check_command                  check_nrpe!check_mongo_replica
}
EOF
}
add_tomcat_service(){
cat >>${FILE}<<EOF
define service{
      use                            ${SERVICE_TEMPLATE}
      host_name                      ${HNAME}
      service_description            ${HNAME} tomcat服务状态
      check_command                  check_nrpe!check_tomcat_procs
}
EOF
}