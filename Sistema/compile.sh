#!/bin/bash

tput setaf 7 ; tput setab 4 ; tput bold ; printf '%50s%s%-20s\n' "BadVPN, created By Mr.Devim" ; tput sgr0
if [ -f "/usr/local/bin/badvpn-udpgw" ]
then
	tput setaf 3 ; tput bold ; echo ""
	echo ""
	echo "ติดตั้ง BadVPN เรียบร้อยแล้ว"
	echo "วิธีใช้: เปิด session screen"
	echo "แล้วรันคำสั่ง:"
	echo ""
	echo "badudp"
	echo ""
	echo "แล้วปล่อย session screen ทำงานเบื้องหลัง"
	echo "" ; tput sgr0
	exit
else
tput setaf 2 ; tput bold ; echo ""
echo -e "\033[1;36mสคริปต์นี้คอมไพล์และติดตั้ง BadVPN อัตโนมัติบนเซิร์ฟเวอร์ Debian/Ubuntu เพื่อเปิด UDP forwarding บนพอร์ต 7300 ที่ใช้กับโปรแกรมอย่าง HTTP Injector ของ Evozi รองรับการใช้ UDP สำหรับเกมออนไลน์ VoIP และอื่นๆ\033[0m"
echo "" ; tput sgr0
read -p "ต้องการดำเนินการต่อ? [y/n]: " -e -i n resposta
if [[ "$resposta" = 'y' ]]; then
	echo ""
	echo -e "\033[1;31mการติดตั้งอาจใช้เวลานาน... กรุณาอดทนรอ!\033[0m"
	sleep 3
	apt-get update -y
	apt-get install screen wget gcc build-essential g++ make -y
	wget http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz
	tar xvzf cmake*.tar.gz
	cd cmake*
	./bootstrap --prefix=/usr
	make 
	make install
	cd ..
	rm -r cmake*
	mkdir badvpn-build
	cd badvpn-build
	wget https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.tar.gz
	tar xf 1.999.130.tar.gz
	cd bad*
	cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
	make install
	cd ..
	rm -r bad*
	cd ..
	rm -r badvpn-build
    chmod +x badvpn.sh
    ./badvpn.sh
	echo "#!/bin/bash
	badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 512 --max-connections-for-client 8" > /bin/badudp
	chmod +x /bin/badudp
	clear
	tput setaf 3 ; tput bold ; echo ""
	echo ""
	echo -e "\033[1;36mติดตั้ง BadVPN สำเร็จ วิธีใช้: เปิด session screen แล้วรันคำสั่ง badudp และปล่อย session ทำงานเบื้องหลัง\033[0m"
	echo "" ; tput sgr0
	exit
else 
	echo ""
	exit
fi
fi
