#!/bin/bash
set -euo pipefail
clear

# === KONFIGURASI ===
IP=$(curl -sS ipv4.icanhazip.com)
DOMAIN="ltexec.xyz"
SUB=$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)
DNS="${SUB}.${DOMAIN}"

# === CREDENTIAL CLOUDFLARE ===
CF_ID="newvpnlunatix293@gmail.com"
CF_KEY="88a8619c3dec8a0c9a14cf353684036108844"

# === TAMPILAN ===
echo -e "\033[96m=========================================\033[0m"
echo -e "\033[96;1m     MEMBUAT SUBDOMAIN DI CLOUDFLARE     \033[0m"
echo -e "\033[96m=========================================\033[0m"
echo -e "Domain utama : $DOMAIN"
echo -e "Subdomain    : $DNS"
echo -e "IP Server    : $IP"
echo -e "Mode Proxy   : \033[31mOFF (DNS-Only)\033[0m"
echo ""

# === AMBIL ZONE ID DOMAIN ===
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=active" \
  -H "X-Auth-Email: $CF_ID" \
  -H "X-Auth-Key: $CF_KEY" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# === CEK RECORD SUDAH ADA ATAU BELUM ===
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DNS" \
  -H "X-Auth-Email: $CF_ID" \
  -H "X-Auth-Key: $CF_KEY" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

# === BUAT RECORD JIKA BELUM ADA ===
if [[ "${#RECORD_ID}" -lt 10 ]]; then
  echo -e "[+] Menambahkan DNS Record..."
  RECORD_ID=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "X-Auth-Email: $CF_ID" \
    -H "X-Auth-Key: $CF_KEY" \
    -H "Content-Type: application/json" \
    --data '{
      "type": "A",
      "name": "'$DNS'",
      "content": "'$IP'",
      "ttl": 120,
      "proxied": false
    }' | jq -r '.result.id')
else
  echo -e "[✓] Record sudah ada. Melakukan update..."
fi

# === UPDATE RECORD (PASTIKAN PROXIED: FALSE) ===
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "X-Auth-Email: $CF_ID" \
  -H "X-Auth-Key: $CF_KEY" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "'$DNS'",
    "content": "'$IP'",
    "ttl": 120,
    "proxied": false
  }' > /dev/null

# === SIMPAN DOMAIN ===
echo "$DNS" > /etc/xray/domain

clear
echo -e "\033[92m=========================================\033[0m"
echo -e "✅ Subdomain berhasil dibuat:"
echo -e "🔗  \033[1;36m$DNS\033[0m"
echo -e "\033[92m=========================================\033[0m"
sleep 2