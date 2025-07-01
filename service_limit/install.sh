#!/bin/bash

# ====================================
#  LUNATIC TUNNELING - QUOTA SERVICE
#  Author: ian lunatic | Version: v1.0
# ====================================

clear

# === CONFIGURATION ===
BASE_REPO="https://raw.githubusercontent.com/ianexec/LTvpnSystemX/main"
KILLING_REPO="$BASE_REPO/service_limit"
QUOTA_REPO="$BASE_REPO/service_limit"

SYSTEMD_DIR="/etc/systemd/system"
XRAY_DIR="/etc/xray"

KILL_SERVICES=("kill-vme" "kill-vle" "kill-tro" "kill-ssh")
QUOTA_SERVICES=("bwvme" "bwvle" "bwtro")
QUOTA_SCRIPTS=("vmeQUOTA" "vleQUOTA" "troQUOTA")

# === FUNCTION ===
log_success() {
    echo -e "\e[32m[OK]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

# === INSTALL KILL SERVICES ===
echo "🔧 Installing Killing Services..."
for service in "${KILL_SERVICES[@]}"; do
    TARGET="$SYSTEMD_DIR/${service}.service"
    URL="${KILLING_REPO}/${service}.service"

    wget -q -O "$TARGET" "$URL"
    if [[ ! -f "$TARGET" ]]; then
        log_error "Failed to download $service"
        exit 1
    fi

    chmod +x "$TARGET"
    systemctl daemon-reload
    systemctl enable --now "$service"

    log_success "Installed and started $service"
done

# === INSTALL QUOTA SERVICES & SCRIPTS ===
echo -e "\n📦 Installing Quota Services & Scripts..."

for i in "${!QUOTA_SERVICES[@]}"; do
    service="${QUOTA_SERVICES[$i]}"
    script="${QUOTA_SCRIPTS[$i]}"
    
    SERVICE_PATH="$SYSTEMD_DIR/${service}.service"
    SCRIPT_PATH="$XRAY_DIR/${script}"

    # Download .service file
    wget -q -O "$SERVICE_PATH" "${QUOTA_REPO}/${service}.service"
    [[ -f "$SERVICE_PATH" ]] && chmod +x "$SERVICE_PATH" || { log_error "Missing $service.service"; continue; }

    # Download Python quota limiter
    wget -q -O "$SCRIPT_PATH" "${QUOTA_REPO}/quota-${script:0:3}.py"
    [[ -f "$SCRIPT_PATH" ]] && chmod +x "$SCRIPT_PATH" || { log_error "Missing script $script"; continue; }

    # Enable systemd service
    systemctl daemon-reload
    systemctl enable --now "$service"
    
    log_success "$service installed and running"
done

echo -e "\n✅ \e[1mAll quota services installed successfully.\e[0m"
