#!/bin/bash
# LUNATIC TCP BBR OPTIMIZER
# Author: ianexec | https://github.com/ianexec

clear
rm -f "$0"  # Hapus diri sendiri setelah dieksekusi

# ===================[ Warna Terminal ]===================
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

# ===================[ Tambah Baris jika belum ada ]===================
Add_To_New_Line() {
    [[ "$(tail -n1 "$1" | wc -l)" == "0" ]] && echo "" >> "$1"
    echo "$2" >> "$1"
}

Check_And_Add_Line() {
    grep -qF -- "$2" "$1" || Add_To_New_Line "$1" "$2"
}

# ===================[ Install TCP BBR ]===================
Install_BBR() {
    echo -e "${BLUE}----------------------------------------${NC}"
    echo -e "${YELLOW} [•] Install TCP BBR...${NC}"
    
    if lsmod | grep -q bbr; then
        echo -e "${GREEN} [✓] TCP BBR sudah aktif.${NC}"
        echo -e "${BLUE}----------------------------------------${NC}"
        return
    fi

    modprobe tcp_bbr
    Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
    Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
    Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
    sysctl -p >/dev/null 2>&1

    if sysctl net.ipv4.tcp_congestion_control | grep -q bbr && lsmod | grep -q tcp_bbr; then
        echo -e "${GREEN} [✓] TCP BBR berhasil diaktifkan.${NC}"
    else
        echo -e "${RED} [✗] Gagal mengaktifkan TCP BBR.${NC}"
    fi
    echo -e "${BLUE}----------------------------------------${NC}"
}

# ===================[ Optimasi Kernel Parameters ]===================
Optimize_Parameters() {
    echo -e "${YELLOW} [•] Optimasi kernel & network parameters...${NC}"

    limits_file="/etc/security/limits.conf"
    sysctl_file="/etc/sysctl.conf"

    # Limits
    Check_And_Add_Line "$limits_file" "* soft nofile 51200"
    Check_And_Add_Line "$limits_file" "* hard nofile 51200"
    Check_And_Add_Line "$limits_file" "root soft nofile 51200"
    Check_And_Add_Line "$limits_file" "root hard nofile 51200"

    # Sysctl
    param_list=(
        "fs.file-max = 51200"
        "net.core.rmem_max = 67108864"
        "net.core.wmem_max = 67108864"
        "net.core.netdev_max_backlog = 250000"
        "net.core.somaxconn = 4096"
        "net.ipv4.tcp_syncookies = 1"
        "net.ipv4.tcp_tw_reuse = 1"
        "net.ipv4.tcp_fin_timeout = 30"
        "net.ipv4.tcp_keepalive_time = 1200"
        "net.ipv4.ip_local_port_range = 10000 65000"
        "net.ipv4.tcp_max_syn_backlog = 8192"
        "net.ipv4.tcp_max_tw_buckets = 5000"
        "net.ipv4.tcp_fastopen = 3"
        "net.ipv4.tcp_mem = 25600 51200 102400"
        "net.ipv4.tcp_rmem = 4096 87380 67108864"
        "net.ipv4.tcp_wmem = 4096 65536 67108864"
        "net.ipv4.tcp_mtu_probing = 1"
    )

    for param in "${param_list[@]}"; do
        Check_And_Add_Line "$sysctl_file" "$param"
    done

    sysctl -p >/dev/null 2>&1

    echo -e "${GREEN} [✓] Kernel & network tuning selesai.${NC}"
    echo -e "${BLUE}----------------------------------------${NC}"
}

# ===================[ Eksekusi ]===================
Install_BBR
Optimize_Parameters
