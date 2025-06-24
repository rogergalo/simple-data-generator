#!/bin/bash
# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Kick off osquery-setup.sh
echo "Loading Elastic Rules"
curl -X PUT "http://localhost:30001/api/detection_engine/rules/prepackaged" -u "sdg:changme"  --header "kbn-xsrf: true" -H "Content-Type: application/json"  -d '{}'

curl -X POST "http://localhost:30001/api/detection_engine/rules/_bulk_create" -u "sdg:changeme" --header "kbn-xsrf: true" -H "Content-Type: application/json" -d @/root/simple-data-generator/detection-rules/detection-rules/getting-data-ingested-security-sprinkles.json
