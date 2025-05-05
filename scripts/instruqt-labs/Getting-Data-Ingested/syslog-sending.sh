#!/bin/bash

# Define the configuration file path
CONFIG_FILE="/etc/rsyslog.d/syslog.conf"

# Create the rsyslog configuration
cat <<EOF | sudo tee "$CONFIG_FILE" > /dev/null
*.* @kubernetes-vm:514
EOF

# Restart the rsyslog service to apply the changes
echo "Restarting rsyslog to apply configuration..."
sudo systemctl restart rsyslog

# Confirm success
echo "Syslog forwarding configured: all messages to kubernetes-vm:514/UDP"
