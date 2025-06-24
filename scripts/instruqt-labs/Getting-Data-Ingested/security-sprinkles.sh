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

# Define the URL and filename
URL="https://downloads.plex.tv/plex-media-server-new/1.41.8.9834-071366d65/debian/plexmediaserver_1.41.8.9834-071366d65_amd64.deb"
FILE="plexmediaserver_1.41.8.9834-071366d65_amd64.deb"

# Download the file
wget "$URL" -O "$FILE"

# Install the package
sudo dpkg -i "$FILE"
