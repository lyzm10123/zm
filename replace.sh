vim sd.sh

#!/bin/bash
# 检查
# 检索目录
dir="/bak/nginx-conf/conf/"

# 取出指定检索目录下所有的文档
doc=`find $dir -type f`
# 检查并输出检索结果,
for line in $doc
do
	grep -nE '192.168.10.171' $line |grep -E '(3002|3004|3322|3333|3344|3355|3366|3377|3394|3396)' > check_result.txt
done

if [ ! -s check_result.txt ]
then
  echo "替换成功"
else
  echo "替换失败"
fi
