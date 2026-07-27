#!/bin/bash

# Rigctld Service Installation Script
# This script installs hamlib, creates service files, and enables/start services

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Get the username of the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    USERNAME="$SUDO_USER"
else
    USERNAME="$(whoami)"
fi

print_status "Using username: $USERNAME"

# Step 1: Install hamlib-utils
print_status "Installing hamlib-utils..."
apt update
apt install -y libhamlib-utils

# Step 2: Create rigctld1.service
print_status "Creating rigctld1.service..."
cat > /etc/systemd/system/rigctld1.service << EOF
[Unit]
Description=Rigctld Service 1
After=network.target

[Service]
Type=simple
User=$USERNAME
ExecStart=/usr/bin/rigctld -m 2040 -r localhost:19090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Create rigctld2.service
print_status "Creating rigctld2.service..."
cat > /etc/systemd/system/rigctld2.service << EOF
[Unit]
Description=Rigctld Service 2
Requires=rigctld1.service
After=rigctld1.service

[Service]
Type=simple
User=$USERNAME
ExecStart=/usr/bin/rigctld -m 2 -r localhost:4532 -t 4533 -T 0.0.0.0
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Step 4: Reload systemd daemon
print_status "Reloading systemd daemon..."
systemctl daemon-reload

# Step 5: Enable services
print_status "Enabling services..."
systemctl enable rigctld1.service
systemctl enable rigctld2.service

# Step 6: Start services
print_status "Starting services..."
systemctl start rigctld1.service
systemctl start rigctld2.service

# Step 7: Check status
print_status "Checking service status..."
sleep 2  # Give services a moment to start

echo -e "\n${GREEN}=== Service Status ===${NC}"
systemctl status rigctld1.service --no-pager
echo -e "\n${GREEN}=== Service Status ===${NC}"
systemctl status rigctld2.service --no-pager

# Check if services are running
if systemctl is-active --quiet rigctld1.service && systemctl is-active --quiet rigctld2.service; then
    print_status "✅ Both services are running successfully!"
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo "Services will start automatically on boot."
else
    print_warning "Some services may not have started correctly."
    echo "Check logs with: sudo journalctl -u rigctld1.service"
    echo "                  sudo journalctl -u rigctld2.service"
fi

# Show helpful commands
echo -e "\n${GREEN}=== Useful Commands ===${NC}"
echo "Check service status: sudo systemctl status rigctld1.service"
echo "Stop service:          sudo systemctl stop rigctld1.service"
echo "Restart service:       sudo systemctl restart rigctld1.service"
echo "View logs:            sudo journalctl -u rigctld1.service -f"
echo "View all logs:        sudo journalctl -u rigctld*.service -f"
