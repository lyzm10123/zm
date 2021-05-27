#!/bin/bash
tidb_url="http://www.zhidianbao.cn/qs_qingqiu/oldapi/api/local-statis/desktop/querySpace"
#tidb_url="https://bigdatadev.qsban.cn/qsxxwapdev/api/local-statis/"

#不同的的主机对应不同的主机名,tidb1  tidb2 tidb3
hostname="tidb2"

# space_total 节点总空间
space_total=`df -hT -B 1G /erp |tail -1 |awk '{print $3}'`

#used_space 已经使用空间
used_space_G=`df -hT -B 1G /erp |tail -1 |awk '{print $4}'`

#used_percent   已使用百分比
used_percent=`df -hT -B 1G /erp |tail -1 |awk '{print $6}'|cut -d "%" -f 1`

#curl -X POST -d 'node_name=${hostname}&space_total=${space_total}' -d 'used_space_G=${used_space_G}' -d 'used_percent=${used_percent}' $tidb_url
#curl -X POST -d '$node_name&$space_to' -d '$used_space' -d '$used_per'  $tidb_url

node_name="node_name=${hostname}"
space_to="space_total=${space_total}"
used_space="used_space_G=${used_space_G}"
used_per="used_percent=${used_percent}"

#echo ${node_name}
#echo ${space_to}
#echo ${used_space}
#echo ${used_per}

curl -X POST -d "${node_name}&${space_to}" -d "${used_space}" -d "${used_per}"  $tidb_url




