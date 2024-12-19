# Load enrich-bluecoat index data
curl -X POST "http://localhost:30920/enrich-bluecoat/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-bluecoat.ndjson

# Create the enrich-bluecoat enrichment
curl -X PUT "http://localhost:30920/_enrich/policy/enrich-bluecoat" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-bluecoat",
    "match_field": "proxcode",
    "enrich_fields": ["event.action", "event.category", "event.dataset", "event.kind", "event.module", "event.outcome", "event.type", "proxy.category"]
  }
}
EOF

# Initiate enrich-bluecoat enrichment policy
curl -X POST "http://localhost:30920/_enrich/policy/enrich-bluecoat/_execute" -u "sdg:changeme"

# Add enrich-bluecoat ingest pipeline
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-bluecoat" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-bluecoat.json

# Clear the screen
clear

# Run cmatrix in the background
cmatrix -b -u 5 &

# Get the process ID of cmatrix to stop it later
MATRIX_PID=$!

# Wait for 2 seconds to let cmatrix start
sleep 2

# Hide cursor
tput civis

# Get terminal dimensions
rows=$(tput lines)
cols=$(tput cols)

# Center the message
message="Loading, please stand by."
message_length=${#message}
center_col=$(( (cols - message_length) / 2 ))
center_row=$(( rows / 2 ))

# Print the message in the center
tput cup $center_row $center_col
echo "$message" | cowsay

# Wait for 8 seconds with the message displayed
sleep 8

# Kill cmatrix process
kill $MATRIX_PID

# Show cursor again and clear screen
tput cnorm
clear




echo "You took the red pill, now we will see how far the rabbit hole goes."
echo 
echo
echo 
echo
# cd simple-data-generator && gradle clean; gradle build fatJar
echo "Starting data ingestion, press CTRL + C to unplug from the Matrix."
java -jar /root/simple-data-generator/build/libs/simple-data-generator-1.0.0-SNAPSHOT.jar /root/simple-data-generator/secops-proxy.yml
