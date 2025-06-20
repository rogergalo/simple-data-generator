#!/bin/bash
# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Kick off osquery-setup.sh
bash /root/simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/osquery-setup.sh

# Kick off syslog-receiving.sh
bash /root/simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/syslog-receiving.sh

# Kick off install-fim-chaos.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/install-fim-chaos.sh
