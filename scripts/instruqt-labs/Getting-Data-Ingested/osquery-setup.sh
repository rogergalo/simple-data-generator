#!/bin/bash

set -e

# Ensure we are root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Install prerequisites
apt update
apt install -y gnupg lsb-release wget

# Add the osquery repository and key
OSQUERY_KEY_URL="https://pkg.osquery.io/gpg.key"
OSQUERY_REPO="deb [arch=amd64] https://pkg.osquery.io/deb deb main"

wget -qO - "$OSQUERY_KEY_URL" | gpg --dearmor -o /etc/apt/trusted.gpg.d/osquery.gpg
echo "$OSQUERY_REPO" > /etc/apt/sources.list.d/osquery.list

# Install osquery
apt update
apt install -y osquery

# Copy default configuration and enable all packs
mkdir -p /etc/osquery
cp /usr/share/osquery/osquery.example.conf /etc/osquery/osquery.conf

# Enable all packs dynamically
PACKS_DIR="/usr/share/osquery/packs"
CONFIG_FILE="/etc/osquery/osquery.conf"

# Remove any old packs section
sed -i '/"packs": {/,/},/d' "$CONFIG_FILE"

# Build new packs section
echo '"packs": {' >> /tmp/packs.json
first=true
for pack in "$PACKS_DIR"/*.conf; do
  name=$(basename "$pack" .conf)
  if [ "$first" = true ]; then
    first=false
  else
    echo ',' >> /tmp/packs.json
  fi
  echo "  \"$name\": \"$pack\"" >> /tmp/packs.json
done
echo '}' >> /tmp/packs.json

# Insert packs into config
jq --slurpfile packs /tmp/packs.json '.packs = $packs[0].packs' "$CONFIG_FILE" > /etc/osquery/osquery.conf.tmp
mv /etc/osquery/osquery.conf.tmp /etc/osquery/osquery.conf
rm /tmp/packs.json

# Enable and start the service
systemctl enable osqueryd
systemctl start osqueryd

echo "✅ Osquery has been installed and all available packs have been enabled."
