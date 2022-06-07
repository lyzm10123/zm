#!/bin/bash
#$name=""
echo "虚拟机列表"
virsh list --all
read -p "Input vmname or exit: " name
if [ $name == "exit" ]
then
	exit 0
fi

virsh destroy $name
#sleep 2s
while true
do
	snap=`virsh snapshot-list --domain $name |awk '{print $1}' |tail -n +3  |grep -vE '^$'`
	if [ $? -eq 0 ];then
		for line in $snap
		do
			echo "开始删除快照 $line"
			virsh snapshot-delete --domain $name --snapshotname $line
		done
	else
		echo "$line 无快照"
	fi
	break
done

virsh undefine $name
#sleep 2s
rm -rf /opt/kvm/xml/$name.xml
rm -rf /opt/kvm/qcow2/$name.qcow2

