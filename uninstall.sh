#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Uninstalling MTHAN VPS Platform...${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root.${NC}"
  exit 1
fi

# Detect port from config
CONFIG_FILE="/root/.mthan/vps/config.yaml"
PORT=8080
if [ -f "$CONFIG_FILE" ]; then
    PORT=$(grep "port:" "$CONFIG_FILE" | sed 's/.*port: //' | tr -d ' "')
fi

# Cleanup Firewall
echo "Cleaning up firewall rules..."
if [ -n "$PORT" ]; then
    # Cleanup UFW
    if command -v ufw >/dev/null; then
        if ufw status | grep -q "Status: active"; then
            echo "Closing port $PORT in UFW..."
            ufw delete allow "$PORT/tcp"
        fi
    fi
    # Cleanup Firewalld
    if command -v firewall-cmd >/dev/null; then
        if firewall-cmd --state >/dev/null 2>&1; then
            echo "Closing port $PORT in firewalld..."
            firewall-cmd --permanent --remove-port="$PORT/tcp"
            firewall-cmd --reload
        fi
    fi
fi

# Stop and disable all mthan-* services
echo "Stopping all MTHAN services..."
for service in $(systemctl list-unit-files 'mthan-*' --no-legend | awk '{print $1}'); do
    echo "Removing service: $service"
    systemctl stop "$service" || true
    systemctl disable "$service" || true
    rm -f "/etc/systemd/system/$service"
done

systemctl daemon-reload

echo "Removing application binaries and data..."

# Remove the mthan bin directory
if [ -d /usr/local/bin/mthan ]; then
    echo "Removing /usr/local/bin/mthan directory..."
    rm -rf /usr/local/bin/mthan
fi

# Remove the working directory
if [ -d /root/.mthan ]; then
    echo "Removing /root/.mthan directory..."
    rm -rf /root/.mthan
fi

echo -e "${GREEN}MTHAN VPS Platform has been completely uninstalled.${NC}"
