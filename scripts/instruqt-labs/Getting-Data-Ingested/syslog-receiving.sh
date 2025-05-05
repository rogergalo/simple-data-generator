#!/bin/bash

# Ensure UFW is installed
if ! command -v ufw >/dev/null 2>&1; then
  echo "ufw is not installed. Installing..."
  sudo apt-get update && sudo apt-get install -y ufw
fi

# Allow UDP traffic on port 514
echo "Allowing UDP traffic on port 514..."
sudo ufw allow 514/udp

# Enable UFW if not already enabled
if sudo ufw status | grep -q "Status: inactive"; then
  echo "Enabling ufw firewall..."
  sudo ufw --force enable
fi

# Show the updated firewall rules
echo "Updated UFW rules:"
sudo ufw status verbose


# Path for the rsyslog configuration
CONFIG_FILE="/etc/rsyslog.d/syslog.conf"

# Ensure rsyslog is installed
if ! command -v rsyslogd >/dev/null 2>&1; then
  echo "rsyslog is not installed. Installing..."
  sudo apt-get update && sudo apt-get install -y rsyslog
fi

# Enable UDP syslog reception
echo "Creating rsyslog configuration to receive syslog over UDP..."

sudo bash -c "cat > $CONFIG_FILE" <<EOF
# Provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")
EOF

# Restart rsyslog to apply changes
echo "Restarting rsyslog..."
sudo systemctl restart rsyslog

# Confirm that UDP port 514 is listening
echo "Verifying rsyslog is listening on UDP port 514:"
sudo ss -uln | grep ':514'
