#!/bin/bash

# PiHPSDR RigCtld Service Installer
# Makes rigctld permanent across system reboots

set -e

echo "Installing PiHPSDR RigCtld Service..."

# Check if Hamlib is installed
if ! command -v rigctld &> /dev/null; then
    echo "Hamlib not found. Installing..."
    sudo apt update
    sudo apt install -y libhamlib-utils
fi

# Copy service file
echo "Creating systemd service..."
sudo cp rigctld-pihpsdr.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
echo "Enabling and starting service..."
sudo systemctl enable rigctld-pihpsdr.service
sudo systemctl start rigctld-pihpsdr.service

# Check status
echo "Checking service status..."
sudo systemctl status rigctld-pihpsdr.service --no-pager

# Test connection
echo ""
echo "Testing connection to rigctld..."
sleep 2

if command -v nc &> /dev/null; then
    if echo "f" | nc localhost 4533 2>/dev/null; then
        echo "✅ Service is working!"
    else
        echo "⚠️  Service is running but test failed. Check logs with:"
        echo "sudo journalctl -u rigctld-pihpsdr.service -f"
    fi
else
    echo "Install netcat to test: sudo apt install netcat-openbsd"
fi

echo ""
echo "Installation complete! Service will start automatically on boot."
echo ""
echo "Management commands:"
echo "  Status:  sudo systemctl status rigctld-pihpsdr.service"
echo "  Logs:    sudo journalctl -u rigctld-pihpsdr.service -f"
echo "  Restart: sudo systemctl restart rigctld-pihpsdr.service"
echo "  Stop:    sudo systemctl stop rigctld-pihpsdr.service"