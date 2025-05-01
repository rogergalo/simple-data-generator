#!/bin/bash
set -e

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Install prerequisites
apt-get update
apt-get install -y curl gnupg lsb-release wget software-properties-common jq \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Add osquery GPG key and repository
OSQUERY_KEY_URL="https://pkg.osquery.io/deb/pubkey.gpg"
curl -fsSL "$OSQUERY_KEY_URL" | gpg --dearmor -o /usr/share/keyrings/osquery-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/osquery-archive-keyring.gpg] https://pkg.osquery.io/deb deb main" \
  > /etc/apt/sources.list.d/osquery.list

# Install osquery
apt-get update
apt-get install -y osquery \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Create configuration directory
mkdir -p /etc/osquery
CONFIG_FILE="/etc/osquery/osquery.conf"
PACKS_DIR="/etc/osquery/packs"

# Download config from a stable tag (osquery 5.11.0)
curl -fsSL https://raw.githubusercontent.com/osquery/osquery/5.11.0/tools/deployment/osquery.example.conf -o "$CONFIG_FILE"

# Download all packs from same version
mkdir -p "$PACKS_DIR"
curl -sL https://github.com/osquery/osquery/archive/refs/tags/5.11.0.tar.gz | \
  tar -xz --strip-components=2 -C "$PACKS_DIR" osquery-5.11.0/packs

# Inject all packs into config
PACKS_JSON=$(jq -n '{packs: {} }')
for pack_file in "$PACKS_DIR"/*.conf; do
  pack_name=$(basename "$pack_file" .conf)
  PACKS_JSON=$(echo "$PACKS_JSON" | jq --arg name "$pack_name" --arg path "$pack_file" '.packs[$name] = $path')
done

jq --argjson packs "$(echo "$PACKS_JSON" | jq '.packs')" '. + {packs: $packs}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Start osquery service
systemctl daemon-reexec
systemctl enable osqueryd
systemctl restart osqueryd

echo "✅ Osquery installed and fully configured with default packs (v5.11.0)."
