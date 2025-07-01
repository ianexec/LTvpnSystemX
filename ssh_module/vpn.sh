#!/bin/bash
# ============================================
# Auto Installer OpenVPN by IanExec (v7project)
# ============================================

REPO="https://raw.githubusercontent.com/ianexec/LTvpnSystemX/main/"
export DEBIAN_FRONTEND=noninteractive

OS=$(uname -m)
MYIP=$(wget -qO- ipinfo.io/ip)
MYIP2="s/xxxxxxxxx/$MYIP/g"
NET_DEV=$(ip -o -4 route show to default | awk '{print $5}')

# Install Paket Dasar
apt update && apt install -y \
    openvpn easy-rsa unzip openssl \
    iptables iptables-persistent

# Setup Direktori
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/

# Ambil File Easy-RSA
wget "${REPO}ssh_module/vpn.zip"
unzip vpn.zip && rm -f vpn.zip
chown -R root:root /etc/openvpn/server/easy-rsa/

# Plugin PAM Auth
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so \
    /usr/lib/openvpn/

# Autostart OpenVPN
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# Enable dan Restart Service
systemctl enable --now openvpn-server@server-tcp
systemctl enable --now openvpn-server@server-udp
/etc/init.d/openvpn restart

# IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# ================================
# Buat Config Client (TCP, UDP, SSL)
# ================================

make_client_config() {
  local proto=$1
  local port=$2
  local filename=$3

  cat > "/etc/openvpn/$filename.ovpn" <<-EOF
client
dev tun
proto $proto
remote xxxxxxxxx $port
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
EOF

  sed -i "$MYIP2" "/etc/openvpn/$filename.ovpn"
  echo '<ca>' >> "/etc/openvpn/$filename.ovpn"
  cat /etc/openvpn/server/ca.crt >> "/etc/openvpn/$filename.ovpn"
  echo '</ca>' >> "/etc/openvpn/$filename.ovpn"
  cp "/etc/openvpn/$filename.ovpn" "/var/www/html/$filename.ovpn"
}

make_client_config tcp 1194 tcp
make_client_config udp 2200 udp
make_client_config tcp 990 ssl

# ========================
# Firewall dan NAT Routing
# ========================

iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o $NET_DEV -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o $NET_DEV -j MASQUERADE
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

iptables-restore < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Finalisasi
systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

# Bersih-bersih
history -c
rm -f /root/vpn.sh
