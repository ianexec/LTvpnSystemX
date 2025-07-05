#!/bin/bash

#┌─────────────────────────────────────┐
#      LUNATIC TUNNELING v8 (PREMIUM)     
#       Powered by Ian | newltxv8.dev     
#         Support Installer all os        
#             Debian 10 11 12            
#             Ubuntu 20 22 24
#                 2014-2025            
#└────────────────────────────────────┘
#  STRUKTUR SCRIPTS:
#├── ianexec/
#    ├── AI/
#    └── BOT WHATSAPP
#├── PACKAGES/
#    ├── port.txt
#    └── tools.sh
#├── Xbw_LIMIT/
#    ├── bwtro.service # service limit quota Trojan 
#    ├── bwvme.service # service limit quota vmess
#    ├── bwvle.service # service limit quota vless
#    ├── quota-tro  # handle quota Trojan
#    ├── quota-vme  # handle quota vmess
#    ├── quota-vle  # handle quota vless
#    └── install.sh # install semua di Xbw_LIMIT
#├── encrypt/
#    └── gzexe # encrypt menu ketika update script
#├── killing_service/
#   ├── kill-ssh.service # service autokill ssh
#   ├── kill-vme.service # service autokill vmess
#   ├── kill-vle.service # service autokill vless
#   ├── kill-tro.service # service autokill trojan
#   └── service.sh       # install semua service di killing_service
#├── menu
#    ├── LunatiX_py
#    ├── LunatiX_sh
#    └── install_menu.sh # install LunatiX_py && LunatiX_sh
#├── ssh/
#├── ws/
#├── xray/

#    ├── ianexec/v7project/
#    ├── install.sh            # installer script
#    ├── domains.sh            # pointing domains       
#    ├── install_cron.sh       # crons job
#    ├── rclone.conf           # token gdrive buat backup
#    └── versi                 # versi script

# run
rm -f $0
clear
apt update
apt install curl -y
apt install wget -y
apt install jq -y
apt install -y mailutils

######### WARNA TERMINAL ##########
NC='\033[0m'
rbg='\033[41;37m'
r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
u='\033[0;35m'
c='\033[0;96m'
w='\033[1;97m'

      function lane_atas() {
      echo -e "${c}┌──────────────────────────────────────────┐${NC}"
      }
      function lane_bawah() {
      echo -e "${c}└──────────────────────────────────────────┘${NC}"
      }

# ================================
# Root Access Check
# ================================
if [ "${EUID}" -ne 0 ]; then
    echo "${r}You need to run this script as root${NC}"
    sleep 2
    exit 0
fi

# ================================
# Fetch IP, ISP, and City if not cached
# ================================
[[ ! -f /root/.isp ]] && curl -sS ipinfo.io/org?token=7a814b6263b02c > /root/.isp
[[ ! -f /root/.city ]] && curl -sS ipinfo.io/city?token=7a814b6263b02c > /root/.city
[[ ! -f /root/.myip ]] && curl -sS ipv4.icanhazip.com > /root/.myip

# ================================
# Export Env Variables
# ================================
export IP=$(cat /root/.myip)
export ISP=$(cat /root/.isp)
export CITY=$(cat /root/.city)
source /etc/os-release

# ================================
# Tanggal dari Server (Google)
# ================================
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")

# ================================
# Remote Authorization Check
# ================================
url_izin="https://raw.githubusercontent.com/ianexec/permission/main/regist"
client=$(curl -sS "$url_izin" | grep "$IP" | awk '{print $2}')
exp=$(curl -sS "$url_izin" | grep "$IP" | awk '{print $3}')
today=$(date +"%Y-%m-%d")
time=$(printf '%(%H:%M:%S)T')
date=$(date +'%d-%m-%Y')

# Hitung sisa hari masa berlaku
d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)
certifacate=$(((d1 - d2) / 86400))

# ================================
# Function: Check Script Access
# ================================
checking_sc() {
    useexp=$(curl -s "$url_izin" | grep "$IP" | awk '{print $3}')
    if [[ "$date_list" < "$useexp" ]]; then
        echo -ne ""
    else
        clear
        echo -e "\033[96m============================================\033[0m"
        echo -e "\033[44;37m           NotAllowed Autoscript         \033[0m"    
        echo -e "\033[96m============================================\033[0m"
        echo -e "\e[95;1m buy / sewa AutoScript installer VPS \e[0m"
        echo -e "\033[96m============================================\033[0m"    
        echo -e "\e[96;1m   1 IP        : Rp.10.000   \e[0m"
        echo -e "\e[96;1m   2 IP        : Rp.15.000   \e[0m"   
        echo -e "\e[96;1m   7 IP        : Rp.40.000   \e[0m"
        echo -e "\e[96;1m   Unli IP     : Rp.150.000  \e[0m"
        echo -e "\e[97;1m   open source : Rp.400.000  \e[0m"       
        echo -e ""
        echo -e "\033[96m============================================\033[0m"
        exit 0
    fi
}

# ================================
# Run the Check
# ================================
checking_sc
clear



function ARCHITECTURE() {
if [[ "$( uname -m | awk '{print $1}' )" == "x86_64" ]]; then
    echo -ne
else
    echo -e "${r} Your Architecture Is Not Supported ( ${y}$( uname -m )${NC} )"
    exit 1
fi

if [[ ${ID} == "ubuntu" || ${ID} == "debian" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo -e " - ${y}Ubuntu 24.10${NC}"    
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    
    exit 0
fi

if [[ ${VERSION_ID} == "10" || ${VERSION_ID} == "11" || ${VERSION_ID} == "12" || ${VERSION_ID} == "20.04" || ${VERSION_ID} == "21.04" || ${VERSION_ID} == "22.04" || ${VERSION_ID} == "23.04" || ${VERSION_ID} == "24.04" || ${VERSION_ID} == "24.10" ]]; then
    echo -ne
else
    echo -e " ${r}This Script only Support for OS"
    echo -e ""
    echo -e " - ${y}Ubuntu 20.04${NC}"
    echo -e " - ${y}Ubuntu 21.04${NC}"
    echo -e " - ${y}Ubuntu 22.04${NC}"
    echo -e " - ${y}Ubuntu 23.04${NC}"
    echo -e " - ${y}Ubuntu 24.04${NC}"
    echo -e " - ${y}Ubuntu 24.10${NC}"        
    echo ""
    echo -e " - ${y}Debian 10${NC}"
    echo -e " - ${y}Debian 11${NC}"
    echo -e " - ${y}Debian 12${NC}"
    
    exit 0
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
}

# call
ARCHITECTURE
clear

function MakeDirectories() {
    # Direktori utama
    local main_dirs=(
        "/etc/xray" "/var/lib/LT" "/etc/lunatic" "/etc/limit"
        "/etc/vmess" "/etc/vless" "/etc/trojan" "/etc/ssh"
    )
    
    local lunatic_subdirs=("vmess" "vless" "trojan" "ssh" "bot")
    local lunatic_types=("usage" "ip" "detail")

    local protocols=("vmess" "vless" "trojan" "ssh")

    for dir in "${main_dirs[@]}"; do
        mkdir -p "$dir"
    done

    for service in "${lunatic_subdirs[@]}"; do
        for type in "${lunatic_types[@]}"; do
            mkdir -p "/etc/lunatic/$service/$type"
        done
    done

    for protocol in "${protocols[@]}"; do
        mkdir -p "/etc/limit/$protocol"
    done

    local databases=(
        "/etc/lunatic/vmess/.vmess.db"
        "/etc/lunatic/vless/.vless.db"
        "/etc/lunatic/trojan/.trojan.db"
        "/etc/lunatic/ssh/.ssh.db"
        "/etc/lunatic/bot/.bot.db"
    )

    for db in "${databases[@]}"; do
        touch "$db"
        echo "& plugin Account" >> "$db"
    done

    touch /etc/.{ssh,vmess,vless,trojan}.db
    echo "IP=" > /var/lib/LT/ipvps.conf
}

MakeDirectories

clear

function DOMAINS_MANAGER() {
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e "\e[97;1m   DOMAINS CHANGES TO VPS    \e[0m"
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e "\e[92;1m 1. Domain sendiri \e[0m"
    echo -e "\e[92;1m 2. Domain random  \e[0m"
    echo -e "\e[97;1m =========================== \e[0m"
    echo -e ""
    read -p "Select choice domain 1-2: " DOMAINS_SELECT

    if [ "$DOMAINS_SELECT" == "1" ]; then
        clear
        echo -e "\e[97;1m =========================== \e[0m"
        echo -e "\e[96;1m      DOMAINS SENDIRI        \e[0m"
        echo -e "\e[97;1m =========================== \e[0m"
        echo -e ""
        read -p "Your domains: " YUDOMAINS
        echo "$YUDOMAINS" > /etc/xray/domain
        echo "$YUDOMAINS" > /root/domain
    elif [ "$DOMAINS_SELECT" == "2" ]; then
        wget https://raw.githubusercontent.com/ianexec/anjink/main/domains.sh \
             -O /tmp/domains.sh >/dev/null 2>&1 && \
             chmod +x /tmp/domains.sh && /tmp/domains.sh
    else
        echo -e "\e[91;1mPilihan tidak valid!\e[0m"
    fi
    clear
}

DOMAINS_MANAGER

clear
function Installasi(){
animation_loading() {
    CMD[0]="$1"
    CMD[1]="$2"
    
    (
        # Hapus file fim jika ada
        [[ -e $HOME/fim ]] && rm -f $HOME/fim
        
        # Jalankan perintah di background dan sembunyikan output
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        
        # Buat file fim untuk menandakan selesai
        touch $HOME/fim
    ) >/dev/null 2>&1 &

    tput civis # Sembunyikan kursor
    echo -ne "  \033[0;32mProcces\033[1;37m- \033[0;33m["
    
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[97;1m#"
            sleep 0.1
        done
        
        # Jika file fim ada, hapus dan keluar dari loop
        if [[ -e $HOME/fim ]]; then
            rm -f $HOME/fim
            break
        fi
        
        echo -e "\033[0;31m]"
        sleep 1
        tput cuu1 # Kembali ke baris sebelumnya
        tput dl1   # Hapus baris sebelumnya
        echo -ne "  \033[0;32mProcess\033[1;37m- \033[0;31m["
    done
    
    echo -e "\033[0;31m]\033[1;37m -\033[1;32m OK!\033[0m"
    tput cnorm # Tampilkan kursor kembali
}

INSTALL_WEBSOCKET() {
wget https://raw.githubusercontent.com/ianexec/anjink/main/websocket_engine/install-ws.sh && chmod +x install-ws.sh && ./install-ws.sh
wget https://raw.githubusercontent.com/ianexec/anjink/main/websocket_engine/banner_ssh.sh && chmod +x banner_ssh.sh && ./banner_ssh.sh
}

INSTALL_BACKUP() {
apt install rclone
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://github.com/ianexec/anjink/raw/main/rclone.conf"
git clone https://github.com/ianexec/wondershaper.git
cd wondershaper
make install
cd
rm -rf wondershaper
    
rm -f /root/set-br.sh
rm -f /root/limit.sh
}

INSTALL_OHP() {
wget https://raw.githubusercontent.com/ianexec/anjink/main/websocket_engine/ohp.sh && chmod +x ohp.sh && ./ohp.sh
}

INSTALL_FEATURE() {
wget https://raw.githubusercontent.com/ianexec/anjink/main/HandlerSentry/install_menu.sh && chmod +x install_menu.sh && ./install_menu.sh
}

INSTALL_UDP_CUSTOM() {
wget https://raw.githubusercontent.com/ianexec/anjink/main/websocket_engine/UDP.sh && chmod +x UDP.sh && ./UDP.sh
}

if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
echo -e "\033[96;1mSETUP OS : $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')\e[0m"
UNTUK_UBUNTU
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
echo -e "\033[96;1mSETUP OS : $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')\e[0m"
UNTUK_DEBIAN
else
echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
fi
}

function UNTUK_DEBIAN(){

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_WEBSOCKET'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
lane_bawah
animation_loading 'INSTALL_BACKUP'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
lane_bawah
animation_loading 'INSTALL_OHP'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_FEATURE'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_UDP_CUSTOM'

}

function UNTUK_UBUNTU(){

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED WEBSOCKET SSH${NC}    ${c}│${NC}"
lane_bawah
animation_loading 'INSTALL_WEBSOCKET'

lane_atas
echo -e "${c}│       ${g}PROCESS INSTALLED BACKUP MENU${NC}${c}      │${NC}"
lane_bawah
animation_loading 'INSTALL_BACKUP'

lane_atas
echo -e "${c}│           ${g}PROCESS INSTALLED OHP${NC}${c}          │${NC}"
lane_bawah
animation_loading 'INSTALL_OHP'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD EXTRA MENU${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_FEATURE'

lane_atas
echo -e "${c}│           ${g}DOWNLOAD UDP CUSTOM${NC}${c}            │${NC}"
lane_bawah
animation_loading 'INSTALL_UDP_CUSTOM'

}

# Tentukan nilai baru yang diinginkan untuk fs.file-max
NEW_FILE_MAX=65535  # Ubah sesuai kebutuhan Anda

# Nilai tambahan untuk konfigurasi netfilter
NF_CONNTRACK_MAX="net.netfilter.nf_conntrack_max=262144"
NF_CONNTRACK_TIMEOUT="net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"

# File yang akan diedit
SYSCTL_CONF="/etc/sysctl.conf"

# Ambil nilai fs.file-max saat ini
CURRENT_FILE_MAX=$(grep "^fs.file-max" "$SYSCTL_CONF" | awk '{print $3}' 2>/dev/null)

# Cek apakah nilai fs.file-max sudah sesuai
if [ "$CURRENT_FILE_MAX" != "$NEW_FILE_MAX" ]; then
    # Cek apakah fs.file-max sudah ada di file
    if grep -q "^fs.file-max" "$SYSCTL_CONF"; then
        # Jika ada, ubah nilainya
        sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" >/dev/null 2>&1
    else
        # Jika tidak ada, tambahkan baris baru
        echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF" 2>/dev/null
    fi
fi

# Cek apakah net.netfilter.nf_conntrack_max sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_MAX" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Cek apakah net.netfilter.nf_conntrack_tcp_timeout_time_wait sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_tcp_timeout_time_wait" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_TIMEOUT" >> "$SYSCTL_CONF" 2>/dev/null
fi


# Terapkan perubahan
sysctl -p >/dev/null 2>&1

function install_crond(){
wget https://raw.githubusercontent.com/ianexec/anjink/main/install_cron.sh && chmod +x install_cron.sh && ./install_cron.sh
clear
}


clear

# install tools.sh
echo -e "\e[91;1m ================================ \e[0m"
echo -e "\e[97;1m    INSTALLED PACKAGES MODULE   \e[0m"
echo -e "\e[91;1m ================================ \e[0m"
cd
wget https://raw.githubusercontent.com/ianexec/anjink/main/tools_network/pkg_installer.sh && chmod +x pkg_installer.sh && ./pkg_installer.sh
wget -q -O /etc/port.txt "https://raw.githubusercontent.com/ianexec/anjink/main/port.txt"

clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install git
apt install python -y >/dev/null 2>&1

clear
echo -e "\e[91;1m ================================ \e[0m"
echo -e "\e[97;1m   INSTALLED SSH-VPN.SH MODULE    \e[0m"
echo -e "\e[91;1m ================================ \e[0m"
# install vpn-ssh.sh
sudo apt install at -y >/dev/null 2>&1

wget https://raw.githubusercontent.com/ianexec/anjink/main/ssh_module/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh

# installer gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb
clear

clear
# install ins-xray.sh
echo -e "\e[91;1m ================================ \e[0m"
echo -e "\e[97;1m   INSTALLED INS-XRAY.SH MODULE   \e[0m"
echo -e "\e[91;1m ================================ \e[0m"
# install semua kebutuhan xray
wget https://raw.githubusercontent.com/ianexec/anjink/main/xray_engine/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear
# limit service ip xray & quota*.py (3)
wget https://raw.githubusercontent.com/ianexec/anjink/main/service_limit/install.sh && chmod +x install.sh && ./install.sh
clear

# call function
Installasi
install_crond

# install cron.d
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
history -c
serverV="4.1"
echo $serverV > /root/.versi
echo "00" > /home/daily_reboot
aureb=$(cat /home/daily_reboot)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
cd

curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp

rm -f /root/*.sh
rm -f /root/*.txt


function SENDER_NOTIFICATION() {
CHATID="7428226275"
KEY="7382456251:AAFFC-8A6VsotlfAQj6MXe4Mff-7MNX5yRs"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="
<code>= = = = = = = = = = = = =</code>
<b>   🧱 AUTOSCRIPT PREMIUM 🧱 </b>
<b>        Notifications       </b>
<code>= = = = = = = = = = = = =</code>
<b>Client  :</b> <code>$client</code>
<b>ISP     :</b> <code>$ISP</code>
<b>Country :</b> <code>$CITY</code>
<b>DATE    :</b> <code>$date</code>
<b>Time    :</b> <code>$time</code>
<b>Expired :</b> <code>$exp</code>
<code>= = = = = = = = = = = = =</code>
<b>        LUNATIC TUNNELING     </b>
<code>= = = = = = = = = = = = =</code>"
curl -s --max-time 10 -X POST "$URL" \
-d "chat_id=$CHATID" \
-d "text=$TEXT" \
-d "parse_mode=HTML" \
-d "disable_web_page_preview=true" \
-d "reply_markup={\"inline_keyboard\":[[{\"text\":\" ʙᴜʏ ꜱᴄʀɪᴘᴛ \",\"url\":\"https://t.me/ian_khvicha\"}]]}"

clear
}

rm ~/.bash_history
rm -f openvpn
rm -f key.pem
rm -f cert.pem
rm -f udp

clear
echo -e "${c}┌────────────────────────────────────────────┐${NC}"
echo -e "${c}│  ${g}INSTALL SCRIPT SELESAI..${NC}                  ${c}│${NC}"
echo -e "${c}└────────────────────────────────────────────┘${NC}"
echo  ""
echo -e "\e[92;1m dalam 3 detik akan Melakukan reboot.... \e[0m"

SENDER_NOTIFICATION

clear
# Langsung reboot
reboot
