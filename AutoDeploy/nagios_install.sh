#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
down_software

log_record download

groupadd nagios
useradd -s /sbin/nologin -g nagios -M nagios

cd  ${SOFTWARE_DIR}${S_NAME}
./configure --prefix=${APP_DIR}${S_NAME}
make && make install
log_record make 
chown -R nagios.nagios ${APP_DIR}${S_NAME}

