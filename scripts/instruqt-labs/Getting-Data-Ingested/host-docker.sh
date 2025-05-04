#!/bin/bash
# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Kick off update-etc_hosts.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/update-etc_hosts.sh

# Kick off osquery-setup.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/osquery-setup.sh

# Kick off mysql-docker-deploy.sh
bash simple-data-generator/scripts/instruqt-labs/Getting-Data-Ingested/mysql-docker-deploy.sh
