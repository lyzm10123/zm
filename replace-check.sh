#!/bin/bash

# 检索目录
dir="/bak/nginx-conf/conf/"
# 源IP
sip="192.168.10.171"
# 目标IP
dip="192.168.10.28"

# 取出指定检索目录下所有的文档
doc=`find $dir -type f`

# 遍历文档
for line in $doc
do
	# 匹配满足条件的行号
	num=`grep -nE '${sip}' $line |grep -E '(3002|3004|3322|3333|3344|3355|3366|3377|3394|3396)' |awk '{print $1}' |cut -d: -f1`
	# 转换
	for i in $num
	do
		sed -i "${i}s/${sip}/${dip}/" $line
	done
done
