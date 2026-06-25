#!/bin/bash
[[ $(screen -list| grep -c 'bot_teste') == '0' ]] && {
    clear
    echo -e "\E[44;1;37m     เปิดใช้งานบอท SSH ทดลอง     \E[0m"
    echo ""
    echo -ne "\n\033[1;32mกรอก โทเค็น\033[1;37m: "
    read token
    [[ -z "$token" ]] && {
        echo -e "\033[1;31m[ผิดพลาด]\033[1;33m เปิดใช้งานบอทไม่สำเร็จ: ไม่ได้กรอก โทเค็น — รันคำสั่งอีกครั้งแล้วกรอก โทเค็น ของบอท Telegram\033[0m"
        exit 1
    }
    clear
    echo "-----------ตัวอย่าง-----------"
    echo "=×=×=×=×=×=×=×=×=×=×=×=×=×="
    echo "   ข้อความต้อนรับ   "
    echo "=×=×=×=×=×=×=×=×=×=×=×=×=×="
    echo "        ข้อความปิดท้าย         "
    echo ""
    echo -ne "\033[1;32mข้อความต้อนรับ:\033[1;37m "
    read bvindo
    echo -ne "\033[1;32mข้อความปิดท้าย:\033[1;37m "
    read mfinal
    clear
    echo -ne "\033[1;32mชื่อปุ่มที่ 1 (ตัวสร้าง SSH):\033[1;37m "
    read bt1
    clear
    echo -ne "\033[1;32mชื่อปุ่มที่ 2 (กำหนดเอง):\033[1;37m "
    read bt2
    echo -ne "\033[1;32mลิงก์ของปุ่มที่ 2:\033[1;37m "
    read link2
    clear
    echo -ne "\033[1;32mชื่อปุ่มที่ 3 (กำหนดเอง):\033[1;37m "
    read bt3
    echo -ne "\033[1;32mลิงก์ของปุ่มที่ 3:\033[1;37m "
    read link3
    clear
    echo -ne "\033[1;32mระยะเวลาทดลอง (หน่วยเป็นชั่วโมง):\033[1;37m "
    read dtempo
    clear
    echo ""
    echo -e "\033[1;32mกำลังเริ่มบอททดลอง กรุณารอสักครู่ \033[0m\n"
    cd $HOME/BOT || {
        echo -e "\033[1;31m[ผิดพลาด]\033[1;33m เข้าโฟลเดอร์ \$HOME/BOT ไม่สำเร็จ: ไม่พบโฟลเดอร์ — ติดตั้งสคริปต์หลักให้เสร็จก่อน หรือสร้างโฟลเดอร์ด้วยคำสั่ง mkdir -p \$HOME/BOT\033[0m"
        exit 1
    }
    rm -rf $HOME/BOT/botssh
    wget https://www.dropbox.com/s/a7i10qa2j1dzri0/botssh >/dev/null 2>&1
    [[ ! -s "$HOME/BOT/botssh" ]] && {
        echo -e "\033[1;31m[ผิดพลาด]\033[1;33m ดาวน์โหลดไฟล์ botssh ไม่สำเร็จ: wget เชื่อมต่อเซิร์ฟเวอร์ดาวน์โหลดไม่ได้ — ตรวจสอบการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่\033[0m"
        exit 1
    }
    chmod 777 botssh
    echo ""
    sleep 1
    sed -i "s/!#bvindo#!/$bvindo/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#mfinal#!/$mfinal/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#bt1#!/$bt1/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#bt2#!/$bt2/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#link2#!/$link2/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#bt3#!/$bt3/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#link3#!/$link3/g" $HOME/BOT/botssh >/dev/null 2>&1
    sed -i "s/!#dtempo#!/$dtempo/g" $HOME/BOT/botssh >/dev/null 2>&1
    sleep 1
    screen -dmS bot_teste ./botssh $token > /dev/null 2>&1
    clear
    echo "เปิดใช้งานบอทแล้ว"
    menu
} || {
    screen -r -S "bot_teste" -X quit
    clear
    echo "ปิดใช้งานบอทแล้ว"
    menu
}
