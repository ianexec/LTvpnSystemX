#!/bin/bash

rm -f $0

file_path="/etc/handeling"
repo="https://raw.githubusercontent.com/ianexec/LTvpnSystemX/main"

apt update
apt install python3 -y
apt install python3-pip -y
apt install python3-requests -y

if [ ! -f "$file_path" ]; then
    echo -e "Lunatic Tunneling\nYellow" | sudo tee "$file_path" > /dev/null
    echo "File '$file_path' berhasil dibuat."
else
    if [ ! -s "$file_path" ]; then
        echo -e "Lunatic Tunneling\nYellow" | sudo tee "$file_path" > /dev/null
        echo "File '$file_path' kosong dan telah diisi."
    else
        echo "File '$file_path' sudah ada dan berisi data."
    fi
fi

cd /usr/local/bin
wget -q -O vpn.zip "${repo}/websocket_engine/vpn.zip"
unzip vpn.zip
cp ws ws-ovpn
chmod +x ws ws-ovpn
rm vpn.zip
cd

# Installing Service
cat > /etc/systemd/system/ws.service << END
[Unit]
Description=Proxy Mod
Documentation=https://google.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ws
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws.service
systemctl start ws.service
systemctl restart ws.service

# Installing Service
cat > /etc/systemd/system/ws-ovpn.service << END
[Unit]
Description=Proxy Mod
Documentation=https://google.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/ws-ovpn 2086
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws-ovpn
systemctl start ws-ovpn
systemctl restart ws-ovpn
