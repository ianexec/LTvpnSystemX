#!/bin/bash
# LUNATIC INSTALLER SCRIPT
# Author: ianexec | https://github.com/ianexec

clear
rm -f "$0"  # auto delete installer after run

# ====================[ WARNA TERMINAL ]====================
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
cyan='\e[1;36m'
white='\e[1;37m'
NC='\e[0m'

# ===================[ PENGECEKAN IZIN IP ]==================
IP=$(curl -sS ipv4.icanhazip.com)
URL_IZIN="https://raw.githubusercontent.com/ianexec/permission/main/regist"
SERVER_DATE=$(curl -s --insecure --silent https://google.com/ | grep Date | sed -e 's/< Date: //')
TODAY=$(date -d "$SERVER_DATE" +"%Y-%m-%d")
EXP=$(curl -sS "$URL_IZIN" | grep "$IP" | awk '{print $3}')
CLIENT=$(curl -sS "$URL_IZIN" | grep "$IP" | awk '{print $2}')

# Hitung sisa masa aktif
d1=$(date -d "$EXP" +%s)
d2=$(date -d "$TODAY" +%s)
REMAIN=$(( (d1 - d2) / 86400 ))

if [[ $TODAY > $EXP ]]; then
    clear
    echo -e "${cyan}============================================${NC}"
    echo -e "${blue}        🚫  AKSES DITOLAK  🚫              ${NC}"    
    echo -e "${cyan}============================================${NC}"
    echo -e "${red}  Masa aktif IP $IP sudah expired!${NC}"
    echo -e "${yellow}  Silakan hubungi admin untuk sewa script.${NC}"
    echo -e "${yellow}  Whatapp : 087764628807 / 083197765857${NC}"    
    echo -e "${cyan}============================================${NC}"
    echo -e "${white}Harga:${NC}"
    echo -e "${yellow}  1 IP        : Rp.5.000  / bulan${NC}"
    echo -e "${yellow}  2 IP        : Rp.10.000 / bulan${NC}"
    echo -e "${yellow}  7 IP        : Rp.40.000 / 2 bulan${NC}"
    echo -e "${yellow}  Unlimited   : Rp.150.000 / 1 tahun${NC}"
    echo -e "${yellow}  OpenSource  : Rp.300.000 / hak milik${NC}"
    echo -e "${cyan}============================================${NC}"
    exit 1
fi

# ===================[ UPDATE & INSTALL DEPENDENCIES ]===================
echo -e "${blue}[•] Proses install dependencies...${NC}"
sleep 1

apt update -y
apt upgrade -y
apt dist-upgrade -y
apt install -y sudo debconf-utils p7zip-full haproxy \
  iptables iptables-persistent netfilter-persistent \
  software-properties-common figlet ruby screen curl jq \
  gzip coreutils rsyslog iftop htop zip unzip net-tools \
  sed gnupg bc build-essential lsb-release chrony \
  openssl openvpn easy-rsa fail2ban tmux stunnel4 dropbear \
  socat cron bash-completion ntpdate xz-utils dnsutils \
  gnupg2 neofetch screenfetch lsof python-is-python3 \
  python3-pip shc nodejs nginx php php-fpm php-cli php-mysql \
  libjpeg-dev zlib1g-dev libnss3-dev libnspr4-dev pkg-config \
  libpam0g-dev libcap-ng-dev libcap-ng-utils libselinux1-dev \
  libcurl4-openssl-dev flex bison make libevent-dev xl2tpd git \
  speedtest-cli

# hapus firewall bawaan
apt-get remove --purge -y ufw firewalld exim4 apache2* samba* bind9* sendmail*

# konfigurasi iptables-persistent otomatis
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

# ===================[ INSTALL GOTOP ]===================
gotop_version=$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | head -n 1 | sed -E 's/.*"v(.*)".*/\1/')
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v${gotop_version}/gotop_v${gotop_version}_linux_amd64.deb"

echo -e "${blue}[•] Menginstall gotop monitoring tool...${NC}"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb >/dev/null 2>&1

# ===================[ CLEANING ]===================
echo -e "${blue}[•] Pembersihan file dan paket tidak penting...${NC}"
apt-get autoremove -y >/dev/null 2>&1
apt-get autoclean -y >/dev/null 2>&1

# Fix typo & penghapusan tambahan (silent)
apt-get -y --purge remove unscd >/dev/null 2>&1

# ===================[ DONE ]===================
echo -e "${green}[✔] Dependencies berhasil di-install.${NC}"
echo -e "${cyan}============================================${NC}"
