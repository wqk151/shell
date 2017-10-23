#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/29"
#__time__="11:09"
# 一共三个文件
# shell 脚本
cat host.list | while read id
do
    ip=`echo $id | awk '{print $1}'`
    user=`echo $id | awk '{print $2}'`
    passwd=`echo $id | awk '{print $3}'`
    # 注意格式
    /data/apps/expect/bin/expect /sh/copy_key.sh $ip $user $passwd
done


# expect 脚本
# 注意expect路径
#!/data/apps/expect/bin/expect -f
set ip [lindex $argv 0]
set user [lindex $argv 1]
set passwd [lindex $argv 2]
#set timeout 10
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user@$ip
expect {
"*/no)" { send "yes\r"; exp_continue }
"*password:" { send "$passwd\r" }
}
#interact
expect off

# host.list格式
192.168.4.131 root 123456
192.168.4.130 root 123456
192.168.4.129 root 123456