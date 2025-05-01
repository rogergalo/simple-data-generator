#!/bin/bash

# Get the IP address of kubernetes-vm
IP=$(getent hosts kubernetes-vm | awk '{ print $1 }')

# Check if IP was found
if [[ -z "$IP" ]]; then
  echo "Could not resolve kubernetes-vm"
  exit 1
fi

# Backup current hosts file
sudo cp /etc/hosts /etc/hosts.bak

# Indent existing lines by 3 spaces and write back
sudo sed 's/^/   /' /etc/hosts.bak > /tmp/hosts.tmp

# Add the new mapping at the end
echo "$IP fleet-server-agent-http.default.svc" >> /tmp/hosts.tmp

# Replace the original file
sudo mv /tmp/hosts.tmp /etc/hosts

echo "Updated /etc/hosts with indentation and alias: fleet-server-agent-http.default.svc -> $IP"
