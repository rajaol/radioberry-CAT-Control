#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

# Get the actual user who invoked sudo
CURRENT_USER=${SUDO_USER:-$USER}

echo "Updating package list and installing libhamlib-utils..."
apt update && apt install -y libhamlib-utils

echo "Creating rigctld1.service..."
cat <<EOF > /etc/systemd/system/rigctld1.service
[Unit]
Description=Rigctld Service 1
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
ExecStart=/usr/bin/rigctld -m 2040 -r localhost:19090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Creating rigctld2.service..."
cat <<EOF > /etc/systemd/system/rigctld2.service
[Unit]
Description=Rigctld Service 2
Requires=rigctld1.service
After=rigctld1.service

[Service]
Type=simple
User=$CURRENT_USER
ExecStart=/usr/bin/rigctld -m 2 -r localhost:4532 -t 4533 -T 0.0.0.0
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling and starting services..."
systemctl enable rigctld1.service
systemctl enable rigctld2.service

systemctl start rigctld1.service
systemctl start rigctld2.service

echo "Setup complete. Checking status..."
systemctl status rigctld1.service --no-pager
systemctl status rigctld2.service --no-pager
