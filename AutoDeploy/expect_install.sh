#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh

REMOTE_TCL_NAME=$(ftp.sh find | grep tcl.*.gz)
while :
do
cd $SOFTWARE_DIR && ftp.sh  get -c $REMOTE_TCL_NAME
TCL_MD5_VALUE=$(md5sum tcl.tar.gz |awk '/\<tcl/{print $1}')
TCL_MD5_LIST_VALUE=$(cat ./md5sum_file |awk '/\<tcl/{print $1}')
if [ $TCL_MD5_VALUE != $TCL_MD5_LIST_VALUE ];then
	ftp.sh  get -c $REMOTE_TCL_NAME
	
else
	cd $SOFTWARE_DIR &&  tar zxf tcl.tar.gz
	break	
fi
done
cd  ${SOFTWARE_DIR}tcl/unix
./configure --prefix=/${APP_DIR}tcl --enable-shared && make && make install
cp tclUnixPort.h ../generic/


down_software
log_record download
cd  ${SOFTWARE_DIR}${S_NAME}
./configure --prefix=${APP_DIR}expect --with-tcl=${APP_DIR}tcl/lib --with-tclinclude=../tcl/generic
log_record  configure
make && make install
log_record make
ln -s ${APP_DIR}tcl/bin/expect  ${APP_DIR}${S_NAME}/bin/expect
log_record ln