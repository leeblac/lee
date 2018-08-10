#! /bin/bash
read -p "请输入虚拟机编号(1~99)：" vmnum

#if [ $vmnum -le 9 ];then
#vmnum=0$vmnum
#fi

img_dir=/var/lib/libvirt/images
basevm=CentOS
newvm=Centos$vmnum
num=`echo "$vmnum*1" | bc`

if [  -z $vmnum ];then
        echo "输入为空！！！"
	exit 
elif [ $num  -eq 0 ];then
        echo "非正确输入！！！"
	exit
elif [ $vmnum -le 1 -o $vmnum -gt 99 ];then
        echo "输入的数值不在范围内！！！"
	exit
fi

if [ -e $img_dir/$vmnum ];then
        echo "该虚拟机已存在！！！"
fi

echo -en "正在创建虚拟机，请稍后。。。"
qemu-img create  -f qcow2 -b $img_dir/$basevm.img $img_dir/$newvm.img >/dev/null  
echo -e "\e[32;1m[OK]\e[0m"
sed "/demo/s/demo/$newvm/" $img_dir/demo.xml > /tmp/myvm.xml

echo -en "正在定义虚拟机，请稍后。。。"
virsh define /tmp/myvm.xml &> /dev/null
echo -e "\e[32;1m[OK]\e[0m"

which guestmount > /dev/null
if [ $? -ne 0 ];then
	yum -y install libguestfs > /dev/null
fi

guestmount -d $newvm -i /mnt
echo "DEVICE="eth0"
ONBOOT="yes"
IPV6INIT="no"
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR="192.168.1.$vmnum"
PREFIX="24"
GATEWAY="192.168.1.254"" > /mnt/etc/sysconfig/network-scripts/ifcfg-eth0
	#自动配置IP，CentOS版只能使用1.0网段，使用其他网段需要另外配置

#echo "[redhat]    	
#name=redhat
#baseurl=ftp://192.168.4.254/CentOS  
#enabled=1
#gpgcheck=0"> /mnt/etc/yum.repos.d/rhel7.repo
##自动配置yum,因为每个人的yum源都不一样，所以要改地址

echo "node$vmnum" > /mnt/etc/hostname
umount /mnt
