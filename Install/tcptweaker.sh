#!/bin/bash
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-20s\n' "TCP Tweaker 1.0" ; tput sgr0
if [[ `grep -c "^#PH56" /etc/sysctl.conf` -eq 1 ]]
then
	echo ""
	echo "การตั้งค่า TCP Tweaker ถูกเพิ่มในระบบแล้ว!"
	echo ""
	read -p "ต้องการลบการตั้งค่า TCP Tweaker หรือไม่? [y/n]: " -e -i n resposta0
	if [[ "$resposta0" = 'y' ]]; then
		grep -v "^#PH56
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf > /tmp/syscl && mv /tmp/syscl /etc/sysctl.conf
sysctl -p /etc/sysctl.conf > /dev/null
		echo ""
		echo "ลบการตั้งค่า TCP Tweaker สำเร็จแล้ว"
		echo ""
	exit
	else 
		echo ""
		exit
	fi
else
	echo ""
	echo "นี่คือสคริปต์ทดลอง ใช้งานด้วยความเสี่ยงของคุณเอง!"
	echo "สคริปต์นี้จะแก้ไขการตั้งค่าเครือข่ายของระบบ"
	echo "เพื่อลดความหน่วงและเพิ่มความเร็ว"
	echo ""
	read -p "ดำเนินการติดตั้งต่อ? [y/n]: " -e -i n resposta
	if [[ "$resposta" = 'y' ]]; then
	echo ""
	echo "กำลังแก้ไขการตั้งค่าต่อไปนี้:"
	echo " " >> /etc/sysctl.conf
	echo "#PH56" >> /etc/sysctl.conf
echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf
echo ""
sysctl -p /etc/sysctl.conf
		echo ""
		echo "เพิ่มการตั้งค่า TCP Tweaker สำเร็จแล้ว"
		echo ""
	else
		echo ""
		echo "การติดตั้งถูกยกเลิกโดยผู้ใช้!"
		echo ""
	fi
fi
exit