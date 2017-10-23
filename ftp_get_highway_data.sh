#!/bin/bash
#__author__ = "Administrator"
#__date__="2016/7/5"
#__time__="10:24"
#!/bin/bash
YESTARDAY=$(date -d "1 day ago" +%Y%m%d)
BEFOR_YESTARDAY=$(date -d "2 day ago" +%Y%m%d)
GET_YESTARDAY_DIR=$(ftp.sh ls ./api/highway  |awk '/'${YESTARDAY}'/{print $NF}')
REMOT_DIR=/api/highway
LOCAL_DIR=/data/ftpdata/highway

ftp.sh find .${REMOT_DIR}/${YESTARDAY}  | grep .*.gz  |awk -F'/' '{print $NF}' >${LOCAL_DIR}/file/full_list

down_software(){
#while :
#do
    cd ${LOCAL_DIR}/$2 && ftp.sh  get -c $1
#   SOFTWARE_NAME=$(echo $1 |awk -F'/' '{print $NF}')
#    SOFTWARE_MD5_VALUE=$(md5sum ${SOFTWARE_NAME} |awk '{print $1}')
#    SOFTWARE_MD5_LIST_VALUE=$(cat ${SCRIPT_DIR}md5sum_file |awk '{print $1}')
#    if [ $SOFTWARE_MD5_VALUE != $SOFTWARE_MD5_LIST_VALUE ];then
#            ftp.sh  get -c $1
#    else
#        break
#    fi
#done
}

# 对比目录列表和已下载列表，是否有未下载的文件
diff_file(){
cd ${LOCAL_DIR}/file
diff full_list down_list|sed '1d' |awk '{print $NF}' >${LOCAL_DIR}/file/${YESTARDAY}.txt
}

# 校验每个文件的MD5值，记录下载不完整的文件
md5_file(){
if [ -s ${LOCAL_DIR}/file/down_list ];then
    for h in $(cat ${LOCAL_DIR}/file/down_list)
    do
        cd ${LOCAL_DIR}/${YESTARDAY}
        SOFTWARE_MD5_VALUE=$(md5sum ${h} |awk '{print $1}')
        SOFTWARE_MD5_LIST_VALUE=$(echo ${h}|awk -F'-' '{print $2}'  |awk -F'.' '{print $1}')
        if [ $SOFTWARE_MD5_VALUE != $SOFTWARE_MD5_LIST_VALUE ];then
                echo ${h} >> ${LOCAL_DIR}/file/${YESTARDAY}.txt
        fi
    done
fi
}

# 先下载前天未下载和下载不完整的文件
if [ -s ${LOCAL_DIR}/file/${BEFOR_YESTARDAY}.log ];then
    for h in $(cat ${LOCAL_DIR}/file/${BEFOR_YESTARDAY}.log)
    do
    down_software ${h} ${BEFOR_YESTARDAY}
    done
fi

# 判断昨天是否生成目录，有则下载
if [ -n "${GET_YESTARDAY_DIR}" ];then
    mkdir -p ${LOCAL_DIR}/${YESTARDAY}
    TAR_LISTS=$(ftp.sh find .${REMOT_DIR}/${YESTARDAY} | grep .*.gz)
    for i in ${TAR_LISTS}
    do
    down_software $i ${YESTARDAY}
    done
    ls -l ${LOCAL_DIR}/${YESTARDAY}| grep .*.gz |awk '{print $NF}' >${LOCAL_DIR}/file/down_list
    diff_file
    md5_file
 else
    exit
fi

