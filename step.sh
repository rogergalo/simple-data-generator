#!/bin/bash 
sudo apt update -y
sudo apt install cowsay -y
sudo apt install cmatrix -y

# The line to add to ~/.bashrc
line_to_add='export PATH=$PATH:/usr/games'

# Check if the line already exists in .bashrc to avoid duplicates
if ! grep -Fxq "$line_to_add" ~/.bashrc; then
    # Append the line to the bottom of ~/.bashrc
    echo "$line_to_add" >> ~/.bashrc
    echo "Line added to ~/.bashrc"
else
    echo "Line already exists in ~/.bashrc"
fi

# Reload .bashrc to apply changes
source ~/.bashrc

# Add enrich-user_agent stuff:
curl -X POST "http://localhost:30920/enrich-user_agents/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-user_agents.ndjson
# Create user-agents enrich policy
curl -X PUT "http://localhost:30920/_enrich/policy/user-agents" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-user_agents",
    "match_field": "code",
    "enrich_fields": ["user_agent.os.full"]
  }
}
EOF

curl -X POST "http://localhost:30920/_enrich/policy/user-agents/_execute" -u "sdg:changeme"

curl -X PUT "http://localhost:30920/_index_template/enrich-nginxv2" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
  "properties": {
      "code": {
        "type": "long"
      },
      "event": {
        "properties": {
          "category": {
            "type": "keyword"
          },
          "kind": {
            "type": "keyword"
          },
          "outcome": {
            "type": "keyword"
          },
          "type": {
            "type": "keyword"
          }
        }
      },
      "http": {
        "properties": {
          "request": {
            "properties": {
              "method": {
                "type": "keyword"
              }
            }
          },
          "response": {
            "properties": {
              "status_code": {
                "type": "long"
              }
            }
          },
          "version": {
            "type": "keyword"
          }
        }
      },
      "log": {
        "properties": {
          "file": {
            "properties": {
              "path": {
                "type": "keyword"
              }
            }
          }
        }
      },
      "url": {
        "properties": {
          "original": {
            "type": "keyword"
          }
        }
      }
    }
  },
  "index_patterns": ["enrich-nginxv2*"]
}
EOF

curl -X PUT "http://localhost:30920/_index_template/enrich-windows.sysmon_operational" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
 "properties": {
      "message": {
        "type": "text"
      },
      "wincode": {
        "type": "long"
      },
      "winlog": {
        "properties": {
          "event_id": {
            "type": "keyword"
          }
        }
      }
    }
  },
  "index_patterns": ["enrich-windows.sysmon_operational*"]
}
EOF

curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-nginx" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-nginx.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/nginx-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/nginx-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/timestamp-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/timestamp-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-email" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-email.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/email-filter-rules" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/email-filter-rules.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic-dns" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic-dns.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/logs-network_traffic-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/logs-network_traffic-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic.json
# Clear the screen
clear

# Run cmatrix in the background
cmatrix -b -u 5 &

# Capture the process ID of cmatrix
MATRIX_PID=$!

# Wait a moment to allow cmatrix to start
sleep 2

# Hide the cursor
tput civis

# Define the message and create ASCII art using figlet or toilet
message="You took the red pill, now we will see how far the rabbit hole goes."
ascii_art=$(echo "$message" | figlet -c -w $(tput cols))

# Get terminal dimensions
rows=$(tput lines)
cols=$(tput cols)

# Calculate the position to start displaying the ASCII art at 75% of screen height
art_lines=$(echo "$ascii_art" | wc -l)
start_row=$(( (rows - art_lines) / 2 ))

# Display the ASCII art message in the center
tput cup $start_row 0
echo "$ascii_art"

# Wait 10 seconds
sleep 10

# Stop cmatrix
kill $MATRIX_PID

# Show the cursor again
tput cnorm

# Clear the screen
clear




echo "You took the red pill, now we will see how far the rabbit hole goes."
