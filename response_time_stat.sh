#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/8/9"
#__time__="18:18"
#!/bin/bash
while :
do
echo "`date +%F\ %H:%M:%S` -- `curl -o /dev/null -s -w %{time_connect}:%{time_starttransfer}:%{time_total} http://waas.chesia.lf/PubdcService.hml` " >> c.txt
sleep 1
done