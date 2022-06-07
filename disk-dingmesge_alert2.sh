#!/bin/bash
#
yuzhi=85
yujinstr=""
tileConent="龙岩"
#------du 嵌套查询最大文件夹字方法2个 start 
#找出该分区最大的文件夹目录 使用方法
#sub1 目录参数 1


project_root_path=`pwd`
cd $project_root_path

yujin_maxpath=""
function sub1(){
    path=$1
    loopn=$2

    cd $path

    curpath=`pwd`
    #echo sub1 path=$curpath loopn=$loopn
    du -smh * 2>/dev/null |sort -rh |head -1 > ${project_root_path}/tmp$loopn.txt 
    maxpath=`awk '{print $2}'  ${project_root_path}/tmp$loopn.txt`
    if [ -d $maxpath  ]; then
      loopn=`expr $loopn + 1`
      sub2 $maxpath $loopn
    else
        #echo maxpath=$curpath
        yujin_maxpath=$curpath
         rm -f ${project_root_path}/tmp*.txt
    fi
}

function sub2(){
    path=$1
    loopn=$2

    cd $path
    curpath=`pwd`
    #echo sub2 path=$curpath loopn=$loopn
    du -smh * 2>/dev/null |sort -rh |head -1  > ${project_root_path}/tmp$loopn.txt
    maxpath=`awk '{print $2}'  ${project_root_path}/tmp$loopn.txt`
    if [ -d $maxpath  ]; then
    loopn=`expr $loopn + 1`
      sub1 $maxpath $loopn
    else
        #echo maxpath=$curpath
        yujin_maxpath=$curpath
         rm -f ${project_root_path}/tmp*.txt
    fi
}

#------du 嵌套查询最大文件夹字方法2个 end


#local_ip=`/sbin/ifconfig $wangkaname |grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
#local_ip=`ifconfig ens160 |grep inet |awk '{print $2}'`
local_ip=192.168.10.26
#echo $local_ip
DEV=`df -hP | grep '^/dev/*' | cut -d' ' -f1 | sort`
for I in $DEV
do dev=`df -Ph | grep $I | awk '{print $1}'`
size=`df -Ph | grep $I | awk '{print $2}'`
used=`df -Ph | grep $I | awk '{print $3}'`
free=`df -Ph | grep $I | awk '{print $4}'`
rate=`df -Ph | grep $I | awk '{print $5}'`
mount=`df -Ph | grep $I | awk '{print $6}'`
#echo -e "$I:\tsize:$size\tused:$used\tfree:$free\trate:$rate\tmount:$mount"
F=`echo $rate | awk -F% '{print $1}'`

if [ $F -ge $yuzhi ]; then
    sub1 $mount 1
    yujinstr1="磁盘告警:磁盘使用率:服务器ip=$local_ip,磁盘=$mount,使用率$F%>$yuzhi%"
    maxpath_rongliang=`du -sh $yujin_maxpath|sort -rh |head -2 |awk '{print $1}'` >/dev/null
    yujinstr="$yujinstr1;最大文件夹 容量=$maxpath_rongliang, 路径=$yujin_maxpath; 请尽快处理"
    echo $yujinstr
# 郑"13588033262",雷"13819143901"   ,"at": {"atMobiles": [ "13396537122"]
    curl 'https://oapi.dingtalk.com/robot/send?access_token=bcc691dfb4b08999e678c77258c783685e9d92085e514902608856290a15706a' \
   -H 'Content-Type: application/json' \
   -d '{"msgtype": "text","text": 
   {"content": "'$tileConent:''"$yujinstr"'"}
   ,"at": {"atMobiles": []
   , "isAtAll": false}
   }'
fi
done
