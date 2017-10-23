#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
down_software
log_record download

cd  ${SOFTWARE_DIR}${S_NAME}
./configure --prefix=${APP_DIR}nagios
make all
make install-plugin
make install-daemon
make install-daemon-config
log_record make


#\mv /opt/tool/nagios/tool/nrpe.cfg /usr/local/nagios/etc/
sed -i '/allowed_hosts/s/=.*/='${NAGIOS_HOSTNAME}'/' ${APP_DIR}nagios/etc/nrpe.cfg
echo "${APP_DIR}nagios/bin/nrpe -c ${APP_DIR}nagios/etc/nrpe.cfg -d" >> /etc/rc.local 
#\mv /opt/tool/nagios/tool/check* /usr/local/nagios/libexec/
chmod a+x ${APP_DIR}nagios/libexec/*
chown -R nagios.nagios ${APP_DIR}nagios
${APP_DIR}nagios/bin/nrpe -c ${APP_DIR}nagios/etc/nrpe.cfg -d