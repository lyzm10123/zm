#!/bin/bash
echo "虚拟机列表"
virsh list --all
uuid=$(uuidgen)
read -p "input kvm-name: " name
read -p "input kvm-ip最后一位(两位数): " ip

# create disk qcow2 file and xml file
qemu-img create -b /opt/kvm/qcow2/temp.qcow2 -f qcow2 /opt/kvm/qcow2/$name.qcow2 50G 1> /dev/null
if [ $? -eq 0 ]
then
	echo "$name.qcow2 create success!!"
fi
cp -p /opt/kvm/xml/temp.xml /opt/kvm/xml/$name.xml

sed -i "9s/temp/$name/" /opt/kvm/xml/$name.xml
sed -ri "10s/163183.*/$uuid\<\/uuid\>/" /opt/kvm/xml/$name.xml
sed -i "44s/temp.qcow2/$name.qcow2/"	/opt/kvm/xml/$name.xml
sed -i "78s/54/$ip/" /opt/kvm/xml/$name.xml

virsh define /opt/kvm/xml/$name.xml
virsh start $name
virsh list --all
mac=$(virsh dumpxml $name |grep "mac address" |awk -F["'"] '{print $2}')
hostip=$(arp -a |grep -i $mac |cut -d "(" -f2 |cut -d ')' -f1)

#sleep 10s
#echo "$name : $uuid"
echo "mac ：$mac"
#echo "hostip : $hostip"
echo "#-------------#" >> /opt/kvm-info
echo "$name : $uuid" >> /opt/kvm-info
echo "mac ：$mac"  >> /opt/kvm-info
#/usr/bin/sh /shell/ip-kvm.sh $mac
#echo "hostip : $hostip" >> /opt/kvm-info
