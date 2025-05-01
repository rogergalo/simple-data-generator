#!/bin/bash

set -e

# Ensure we are root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Install prerequisites
apt update
apt install -y curl gnupg lsb-release wget software-properties-common

# Add osquery GPG key and repo
OSQUERY_KEY_URL="https://pkg.osquery.io/deb/pubkey.gpg"
OSQUERY_REPO="deb [signed-by=/usr/share/keyrings/osquery-archive-keyring.gpg] https://pkg.osquery.io/deb deb main"

curl -fsSL "$OSQUERY_KEY_URL" | gpg --dearmor -o /usr/share/keyrings/osquery-archive-keyring.gpg
echo "$OSQUERY_REPO" | tee /etc/apt/sources.list.d/osquery.list

# Install osquery
apt update
apt install -y osquery jq

# Prepare osquery config and enable all packs
mkdir -p /etc/osquery
cp /usr/share/osquery/osquery.example.conf /etc/osquery/osquery.conf

PACKS_DIR="/usr/share/osquery/packs"
CONFIG_FILE="/etc/osquery/osquery.conf"

# Remove old packs section
sed -i '/"packs": {/,/},/d' "$CONFIG_FILE"

# Dynamically enable all packs
PACKS_JSON=$(jq -n '{packs: {} }')
for pack_file in "$PACKS_DIR"/*.conf; do
  pack_name=$(basename "$pack_file" .conf)
  PACKS_JSON=$(echo "$PACKS_JSON" | jq --arg name "$pack_name" --arg path "$pack_file" '.packs[$name] = $path')
done

# Merge with existing config
jq --argjson packs "$(echo "$PACKS_JSON" | jq '.packs')" '. + {packs: $packs}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Enable and start osquery
systemctl enable osqueryd
systemctl start osqueryd

echo "✅ Osquery installed and all packs enabled on Ubuntu 24.04."
