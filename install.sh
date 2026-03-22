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
    apt-get update && apt-get install -y curl git
elif [ -f /etc/redhat-release ]; then
    dnf install -y curl git || yum install -y curl git
elif [ -f /etc/arch-release ]; then
    pacman -Sy --noconfirm curl git
fi

# Parse arguments
IS_REPAIR=false
for arg in "$@"; do
  if [ "$arg" == "--repair" ]; then
    IS_REPAIR=true
  fi
done

# 0. Service & Data Management
if [ "$IS_REPAIR" = true ]; then
    echo "Repair mode: Stopping MTHAN VPS service..."
    systemctl stop mthan-vps.service || true
    echo "Preserving existing data and configurations..."
else
    echo "Clean installation: Stopping and removing ALL MTHAN services..."
    # Stop and disable all services starting with mthan-
    for service in $(systemctl list-unit-files 'mthan-*' --no-legend | awk '{print $1}'); do
        echo "Removing service: $service"
        systemctl stop "$service" || true
        systemctl disable "$service" || true
        rm -f "/etc/systemd/system/$service"
    done
    echo "Removing old application data and configs..."
    rm -rf /root/.mthan
fi

# Reload systemd
systemctl daemon-reload

# 1. Create target directories (mkdir -p preserves existing if they weren't deleted)
echo "Ensuring directories exist..."
mkdir -p /usr/local/bin/mthan
mkdir -p /root/.mthan/vps/data
mkdir -p /root/.mthan/vps/logging
mkdir -p /root/.mthan/vps/database

# 2. Clone repository and deploy
echo "Cloning MTHAN VPS repository to temporary directory..."
TEMP_DIR="/tmp/mthan-install-$(date +%s)"
rm -rf "$TEMP_DIR"
git clone --depth 1 "https://github.com/antoine-mai/mthan-vps.git" "$TEMP_DIR"

echo "Deploying MTHAN VPS binary..."
cp "$TEMP_DIR/mthan/vps" /usr/local/bin/mthan/vps
chmod +x /usr/local/bin/mthan/vps

echo "Deploying maintenance scripts..."
cp "$TEMP_DIR/uninstall.sh" /root/.mthan/vps/uninstall.sh
chmod +x /root/.mthan/vps/uninstall.sh

# Cleanup temp files
rm -rf "$TEMP_DIR"

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

# Default port
DEFAULT_PORT=2205
PORT=$DEFAULT_PORT

# Read port from config if exists
if [ -f "$CONFIG_FILE" ]; then
    DETECTED_PORT=$(grep "port:" "$CONFIG_FILE" | sed 's/.*port: //' | tr -d ' "')
    if [ -n "$DETECTED_PORT" ]; then
        PORT=$DETECTED_PORT
    fi
fi

# Cleanup legacy
rm -f /root/.mthan/vps/Caddyfile

# Improved IP detection (Force IPv4)
IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "YOUR_SERVER_IP")

# 6. Configure Firewall
echo "Configuring firewall..."
if [ -n "$PORT" ]; then
    # Check UFW (Common on Debian/Ubuntu)
    if command -v ufw >/dev/null; then
        echo "Adding UFW rules for ports 80, 443, and $PORT..."
        ufw allow 80/tcp || true
        ufw allow 443/tcp || true
        ufw allow "$PORT/tcp" || true
    fi
    # Check Firewalld (Common on RPM/Arch)
    if command -v firewall-cmd >/dev/null; then
        echo "Adding Firewalld rules for HTTP, HTTPS, and port $PORT..."
        firewall-cmd --permanent --add-service=http || true
        firewall-cmd --permanent --add-service=https || true
        firewall-cmd --permanent --add-port="$PORT/tcp" || true
        firewall-cmd --reload || true
    fi
fi

echo -e "\n${GREEN}============================================${NC}"
if [ "$IS_REPAIR" = true ]; then
    echo -e "${GREEN}   REPAIR COMPLETE${NC}"
else
    echo -e "${GREEN}   INSTALLATION COMPLETE${NC}"
fi
echo -e "${GREEN}============================================${NC}"
echo -e "URL:        http://${IP}:${PORT}"
echo -e "Access:     Login using your Linux system users"
echo -e "To uninstall, run: /root/.mthan/vps/uninstall.sh"
echo -e "IMPORTANT: Ensure port ${PORT} is open in your cloud firewall.\n"
