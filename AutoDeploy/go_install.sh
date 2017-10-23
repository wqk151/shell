#!/bin/bash
SCRIPT_DIR=/data/sh/
source ${SCRIPT_DIR}common_functions.sh
down_software
mv $S_NAME $APP_DIR
log_record download
GO_ROOT_NUM=$(sed -n '/^GO_ROOT/p' /etc/profile  |wc -l)
if [ $GO_ROOT_NUM == 0 ];then
        PATH_NUM=$(sed -n '/^PATH=\$/p' /etc/profile  |wc -l)
        if [ $PATH_NUM == 0 ];then
          echo "GOROOT=${APP_DIR}${S_NAME}"  >> /etc/profile
#          echo "GOPATH=/data/apps/codis" >> /etc/profile
          echo "PATH=\$PATH:\$GOROOT:\$GOROOT/bin"  >> /etc/profile
          echo "export PATH GOROOT" >>/etc/profile
        else
          sed -i '/^PATH=/i\GOROOT='${APP_DIR}''${S_NAME}'' /etc/profile
#          sed -i '/^PATH=/i\GOPATH=/data/apps/codis' /etc/profile
          sed -i '/^PATH\=\$/s/$/\:\$GOROOT\:\$GOROOT\/bin/' /etc/profile
          sed -i '/^export/s/$/ GO_ROOT/' /etc/profile
        fi
        . /etc/profile
fi
#go version