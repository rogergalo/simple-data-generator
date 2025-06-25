#!/bin/bash
# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Kick off Elastic Rule Loading
echo "Loading Elastic Rule"

curl -X POST "http://localhost:30001/api/detection_engine/rules/_bulk_create" -u "sdg:changeme" --header "kbn-xsrf: true" -H "Content-Type: application/json" -d @/root/simple-data-generator/detection-rules/detection-rules/getting-data-ingested-security-sprinkles.json


