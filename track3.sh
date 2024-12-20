# Setup Index Template for proxy events
curl -X PUT "http://localhost:30920/_index_template/bluecoat" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "default_pipeline": "enrich-bluecoat",
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
    "mappings": {
      "properties": {
        "proxy": {
          "type": "object",
          "properties": {
            "request": {
              "type": "object",
              "properties": {
                "bytes": {
                  "type": "long"
                },
                "url": {
                  "eager_global_ordinals": false,
                  "norms": false,
                  "index": true,
                  "store": false,
                  "type": "keyword",
                  "index_options": "docs",
                  "split_queries_on_whitespace": false,
                  "doc_values": true
                }
              }
            },
            "response": {
              "type": "object",
              "properties": {
                "bytes": {
                  "type": "long"
                }
              }
            },
            "category": {
              "type": "keyword"
            }
          }
        },
        "bc": {
          "type": "object",
          "properties": {
            "event": {
              "type": "object",
              "properties": {
                "kind": {
                  "type": "keyword"
                },
                "module": {
                  "type": "keyword"
                },
                "action": {
                  "type": "keyword"
                },
                "type": {
                  "type": "keyword"
                },
                "category": {
                  "type": "keyword"
                },
                "dataset": {
                  "type": "keyword"
                },
                "outcome": {
                  "type": "keyword"
                }
              }
            }
          }
        },
        "data_stream": {
          "dynamic": true,
          "type": "object",
          "enabled": true,
          "properties": {
            "dataset": {
              "type": "keyword"
            }
          },
          "subobjects": true
        },
        "destination": {
          "type": "object",
          "properties": {
            "geo": {
              "type": "object",
              "properties": {
                "location": {
                  "type": "geo_point"
                }
              }
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "source": {
          "type": "object",
          "properties": {
            "geo": {
              "type": "object",
              "properties": {
                "location": {
                  "type": "geo_point"
                }
              }
            },
            "ip": {
              "type": "ip"
            }
          }
        }
      }
    }
  },
  "index_patterns": [
    "bluecoat*",
    "logs-bluecoat*"
  ],
  "composed_of": [
    "ecs@mappings"
  ],
  "ignore_missing_component_templates": [],
  "allow_auto_create": true
}
EOF

curl -X PUT "http://localhost:30920/_index_template/enrich-user_agents" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
    "mappings": {
      "properties": {
        "code": { "type": "long" },
        "user_agent": { "properties": { "os": { "properties": { "full": { "type": "keyword" } } } } }
      }
    }
  },
  "index_patterns": ["enrich-user_agents*"]
}
EOF

# Load enrich-bluecoat index data
curl -X POST "http://localhost:30920/enrich-bluecoat/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-bluecoat.ndjson
curl -X POST "http://localhost:30920/enrich-user_agents/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-user_agents.ndjson

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

curl -X PUT "http://localhost:30920/_enrich/policy/user-agents" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-user_agents",
    "match_field": "code",
    "enrich_fields": ["user_agent.os.full"]
  }
}
EOF

# Initiate enrich-bluecoat enrichment policy
curl -X POST "http://localhost:30920/_enrich/policy/enrich-bluecoat/_execute" -u "sdg:changeme"
curl -X POST "http://localhost:30920/_enrich/policy/user-agents/_execute" -u "sdg:changeme"

# Add enrich-bluecoat ingest pipeline
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-bluecoat" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-bluecoat-pipeline.json

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
