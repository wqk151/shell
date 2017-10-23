#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/29"
#__time__="17:44"
#set -x
mysqllogin="mysql -uroot -p123456"
$mysqllogin -e "insert into object.t1(id,name) values ('$1','$2');"