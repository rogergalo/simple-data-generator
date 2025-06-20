#!/bin/bash
# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Kick off osquery-setup.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/osquery-setup.sh

# Kick off syslog-sending.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/syslog-sending.sh

# Kick off install-fim-chaos.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/install-fim-chaos.sh
