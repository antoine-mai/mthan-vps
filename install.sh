#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- INSTALL LOGIC ---

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   MTHAN APP INSTALLER${NC}"
echo -e "${BLUE}============================================${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This installer must be run as root.${NC}"
  exit 1
fi

echo "Checking and installing dependencies..."
if [ -f /etc/debian_version ]; then
    apt-get update && apt-get install -y git curl
elif [ -f /etc/redhat-release ]; then
    dnf install -y git curl || yum install -y git curl
elif [ -f /etc/arch-release ]; then
    pacman -Sy --noconfirm git curl
fi

# Parse arguments
IS_REINSTALL=false
for arg in "$@"; do
  if [ "$arg" == "--reinstall" ]; then
    IS_REINSTALL=true
  fi
done

# 0. Cleanup old versions
echo "Cleaning up any existing MTHAN services and files..."

# Stop and disable all services starting with mthan-
for service in $(systemctl list-unit-files 'mthan-*' --no-legend | awk '{print $1}'); do
    echo "Removing service: $service"
    systemctl stop "$service" || true
    systemctl disable "$service" || true
    rm -f "/etc/systemd/system/$service"
done

# Reload systemd to recognize removed services
systemctl daemon-reload

# Full cleanup of installation directory
echo "Removing old installation files..."
rm -rf /root/.mthan

# 1. Create target directories
echo "Creating directories..."
mkdir -p /usr/local/bin/mthan
mkdir -p /root/.mthan/vps/data
mkdir -p /root/.mthan/vps/logging
mkdir -p /root/.mthan/vps/database

# 2. Download binary and scripts
echo "Downloading MTHAN VPS Binary to /usr/local/bin/mthan..."
BASE_URL="https://raw.githubusercontent.com/antoine-mai/mthan-public/main"

# Download the vps binary into the mthan folder
wget -q "$BASE_URL/mthan/vps" -O /usr/local/bin/mthan/vps
chmod +x /usr/local/bin/mthan/vps

# Download Uninstall Script
wget -q "$BASE_URL/uninstall.sh" -O /root/.mthan/vps/uninstall.sh
chmod +x /root/.mthan/vps/uninstall.sh

# 4. Create systemd service for MTHAN VPS
echo "Configuring MTHAN VPS service..."

cat <<EOF > /etc/systemd/system/mthan-vps.service
[Unit]
Description=MTHAN VPS Platform Service
After=network.target

[Service]
ExecStart=/usr/local/bin/mthan/vps
WorkingDirectory=/root/.mthan/vps
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 5. Start VPS service
echo "Starting MTHAN VPS service..."
systemctl daemon-reload
systemctl enable mthan-vps.service
systemctl start mthan-vps.service

# 6. Wait a moment for app to generate config if it's first run
sleep 2

CONFIG_FILE="/root/.mthan/vps/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Waiting for application to initialize configuration..."
    sleep 3
fi

# Read port from config
PORT=$(grep "port:" "$CONFIG_FILE" | sed 's/.*port: //' | tr -d ' "')

# Cleanup legacy
rm -f /root/.mthan/vps/Caddyfile

# Improved IP detection (Force IPv4)
IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "YOUR_SERVER_IP")

# 6. Configure Firewall
echo "Configuring firewall..."
if [ -n "$PORT" ]; then
    if command -v ufw >/dev/null; then
        if ufw status | grep -q "Status: active"; then
            echo "Opening port $PORT in UFW..."
            ufw allow "$PORT/tcp"
        fi
    elif command -v firewall-cmd >/dev/null; then
        echo "Opening port $PORT in firewalld..."
        firewall-cmd --permanent --add-port="$PORT/tcp"
        firewall-cmd --reload
    fi
fi

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "URL:        http://${IP}:${PORT}"
echo -e "Access:     Login using your Linux system users"
echo -e "To uninstall, run: /root/.mthan/vps/uninstall.sh"
echo -e "IMPORTANT: Ensure port ${PORT} is open in your cloud firewall.\n"
