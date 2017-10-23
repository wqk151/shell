#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/20"
#__time__="14:28"

REMOT_DIR=api
LOCAL_DIR=$(ftp.sh find ${REMOT_DIR} | grep tar.gz |sed 's/\/[a-z|A-Z|0-9]*.tar.gz/ /')
# LOCAL_DIR=api/expect api/expect/tcl
for d in ${LOCAL_DIR}
do
    if [ ! -d /$d ];then
        mkdir -p /$d
        ftp.sh ls $d  | grep tar.gz  |awk '{print $NF}' >/$d/a.log
        for f in `ftp.sh ls $d  | grep tar.gz|awk '{print $NF}'`
        do
            cd /$d && ftp.sh get -c $d/$f
            sed -i '/'$f'/d' /$d/a.log
        done
    fi
done
