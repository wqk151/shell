#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/6/22"
#__time__="14:38"

# create hostlist first ,input the hostname going to update
for host in $(cat /data/sh/hostlist)
do
ansible $host -m script -a 'tomcat_update.sh'
done
