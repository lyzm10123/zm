#!/bin/bash

# global variables
ip="ip"
user="root"
passwd="passwd"
dumpling="/opt/tidb-toolkit-v4.0.15-linux-amd64/bin/dumpling"
project="project_name"
url="https://oapi.dingtalk.com/robot/send?access_token?"

#set the path to tidb bak files
tidb_files_path="/erp/tidb-bak/"
tidb_files_dir=${tidb_files_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")/$(date -d "yesterday" +"%d")
tar_dir=${tidb_files_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
date1=$(date -d "yesterday" +"%F")
date2=$(date -d "yesterday" +"%d")
tidb_files_tar=${tidb_files_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")/tidb-${date1}.tar.gz
tar_name=$(echo ${tidb_files_tar} |awk -F[/] '{print $NF}')

log_dir="${tidb_files_path}/logs/"
log_name="${log_dir}tidb-${date1}.log"
#log_name="/erp/tidb-bak/logs/tidb_bak-2022-04-09.log"

mkdir -p ${tidb_files_dir}
mkdir -p ${log_dir}

dingalert(){
		bak_time=$(/usr/bin/date -d yesterday +%F" "%T)
         curl -H 'Content-Type: application/json' \
              -d '{"msgtype": "markdown",
                "markdown": {
                 "title":"'"${project}"'-数据库备份'"$1"'",
                "text": "### '"${project}"'-数据库备份 \n > **'"$1"'**  \n >时间：'"${bak_time}"'" 
                },
                 "at": {
                 "isAtAll": true}
                 }' \
                $url
                }

tidb_bak(){
		cd ${tar_dir};
		# tidb bak
		
		${dumpling}  -h ${ip} -u ${user} -p ${passwd} -P 4000 --threads 20  -f '*.*' -f '!INFORMATION_SCHEMA.*' -f '!METRICS_SCHEMA.*' -f '!PERFORMANCE_SCHEMA.*' -f '!*.sc*' -f '!*.tmp*' -f '!*.dim*' -f '!*.sync_table_batch'  -o  ${date2} &> ${log_name}
		#${dumpling}  -h ${ip} -u ${user} -p ${passwd} -P 4000 --threads 20  -f 'test*.*'  -o  ${date2} &> ${log_name}
		
}

tidb_tar(){
		cd ${tar_dir};
		tar -zcvf ${tar_name} ${date2}
		rm -rf ./${date2}
}

tidb_yujing(){
		result=$(grep -i successfully ${log_name})
		if [ -z ${result} &> /dev/null ];then
			dingalert 异常;
			exit
		else
			tidb_tar > /dev/null;
			dingalert 正常;
		fi
}

save_bak(){
		#Set how long do you want to save
		save_days=30
		
		#delete 7 days ago tidb files
		find $tidb_files_path -type f -mtime +${save_days} -exec rm -rf {} \;
		
		#back to nas
		#/usr/bin/ansible 10.1.70.22 -m copy -a "src=${tidb_files_tar} dest='/erp/tidb-bak'"
		remote_ip="10.1.70.22"
		remote_dir="/erp/tidb-bak/"
		remote_date_dir=${remote_dir}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
		
		/usr/bin/ansible ${remote_ip} -m shell -a "mkdir -p ${remote_date_dir}"
		/usr/bin/ansible ${remote_ip} -m copy -a "src=${tidb_files_tar} dest=${remote_date_dir}"
}

tidb_bak
tidb_yujing
save_bak
