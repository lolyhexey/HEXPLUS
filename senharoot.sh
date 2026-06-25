#!/bin/bash
clear

[[ "$(whoami)" != "root" ]] && {
	echo -e "\033[1;31m[ผิดพลาด]\033[1;33m ไม่สามารถแก้ไขรหัสผ่าน root ได้: ต้องรันด้วยสิทธิ์ root — ใช้คำสั่ง sudo su ก่อน\033[0m"
	exit 1
}
[[ ! -f /etc/ssh/sshd_config ]] && {
	echo -e "\033[1;31m[ผิดพลาด]\033[1;33m ไม่พบไฟล์ /etc/ssh/sshd_config: ระบบอาจยังไม่ได้ติดตั้ง OpenSSH server — ติดตั้งด้วย apt install openssh-server แล้วลองใหม่\033[0m"
	exit 1
}

[[ $(grep -c "prohibit-password" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/prohibit-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "without-password" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/without-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PermitRootLogin" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication" /etc/ssh/sshd_config) = '0' ]] && {
	echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
	sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
service ssh restart > /dev/null || {
	echo -e "\033[1;31m[ผิดพลาด]\033[1;33m รีสตาร์ทบริการ SSH ไม่สำเร็จ: ค่าใน sshd_config อาจไม่ถูกต้อง — ตรวจสอบด้วย sshd -t แล้วลองใหม่\033[0m"
}
clear; echo -e "\033[1;32mขั้นตอนต่อไป กรุณากำหนดรหัสผ่าน root\033[0m"; sleep 2s
if passwd; then
	rm senharoot.sh
else
	echo -e "\033[1;31m[ผิดพลาด]\033[1;33m ตั้งรหัสผ่าน root ไม่สำเร็จ: คำสั่ง passwd ถูกยกเลิกหรือรหัสผ่านไม่ผ่านเงื่อนไข — รันคำสั่ง passwd อีกครั้งแล้วกรอกรหัสผ่านให้ตรงกันทั้งสองครั้ง\033[0m"
fi
