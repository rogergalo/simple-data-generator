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


# Create user-agents enrich policy
curl -X PUT "$ELASTICSEARCH_URL/_enrich/policy/user-agents" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-user_agents",
    "match_field": "code",
    "enrich_fields": ["user_agent.os.full"]
  }
}
EOF

curl -X POST "$ELASTICSEARCH_URL/_enrich/policy/user-agents/_execute" -u "sdg:changeme"

curl -X PUT "$ELASTICSEARCH_URL/_index_template/enrich-nginxv2" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
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
    }}
  },
  "index_patterns": ["enrich-nginxv2*"]
}
EOF

curl -X PUT "$ELASTICSEARCH_URL/_index_template/enrich-windows.sysmon_operational" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
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
    }}
  },
  "index_patterns": ["enrich-windows.sysmon_operational*"]
}
EOF

curl -X PUT "$ELASTICSEARCH_URL/_index_template/logs-email" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "default_pipeline": "enrich-email",
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    },
    "mappings": {
      "properties": {
        "event": {
          "type": "object",
          "properties": {
            "reason": {
              "type": "keyword"
            },
            "kind": {
              "type": "keyword"
            },
            "module": {
              "type": "keyword"
            },
            "action": {
              "type": "keyword"
            },
            "category": {
              "type": "keyword"
            },
            "dataset": {
              "type": "keyword"
            }
          }
        },
        "email": {
          "type": "object",
          "properties": {
            "cc": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "attachments": {
              "type": "object",
              "properties": {
                "file": {
                  "type": "object",
                  "properties": {
                    "extension": {
                      "type": "keyword"
                    },
                    "size": {
                      "type": "long"
                    },
                    "mime_type": {
                      "type": "keyword"
                    },
                    "name": {
                      "type": "keyword"
                    },
                    "hash": {
                      "type": "object",
                      "properties": {
                        "sha1": {
                          "type": "keyword"
                        },
                        "sha256": {
                          "type": "keyword"
                        },
                        "md5": {
                          "type": "keyword"
                        }
                      }
                    }
                  }
                }
              }
            },
            "bcc": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "content_type": {
              "type": "keyword"
            },
            "reply_to": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "sender": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "subject": {
              "type": "keyword"
            },
            "from": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "to": {
              "type": "object",
              "properties": {
                "address": {
                  "type": "keyword"
                }
              }
            },
            "direction": {
              "type": "keyword"
            }
          }
        }
      }
    }
  },
  "index_patterns": [
    "logs-email*"
  ],
  "composed_of": [
    "logs-network_traffic.dns@package"
  ],
  "allow_auto_create": true
}
EOF

curl -X PUT "$ELASTICSEARCH_URL/_index_template/enrich-dns" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "default_pipeline": "enrich-logs-network_traffic",
        "number_of_shards": "1",
        "number_of_replicas": "0"
      }
    }
  },
  "index_patterns": [
    "logs-network_traffic.dns*"
  ],
  "composed_of": [
    "ecs@mappings",
    "logs-network_traffic.dns@package"
  ],
  "allow_auto_create": true
}
EOF

# Add enrich-user_agent stuff:
curl -X POST "$ELASTICSEARCH_URL/enrich-user_agents/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-user_agents.ndjson
curl -X POST "$ELASTICSEARCH_URL/enrich-windows.sysmon_operational/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-windows.sysmon_operational.ndjson
curl -X POST "$ELASTICSEARCH_URL/enrich-nginxv2/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-nginxv2.ndjson

curl -X PUT "$ELASTICSEARCH_URL/_enrich/policy/enrich-nginx" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-nginxv2",
    "match_field": "code",
    "enrich_fields": ["event.category", "event.kind", "event.outcome", "event.type", "http.request.method", "http.response.status_code", "http.version", "log.file.path", "url.original"]
  }
}
EOF

curl -X POST "$ELASTICSEARCH_URL/_enrich/policy/enrich-nginx/_execute" -u "sdg:changeme"

curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/enrich-nginx" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-nginx.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/nginx-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/nginx-cleanup.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/timestamp-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/timestamp-cleanup.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/enrich-email" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-email.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/email-filter-rules" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/email-filter-rules.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/enrich-logs-network_traffic-dns" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic-dns.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/logs-network_traffic-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/logs-network_traffic-cleanup.json
curl -X PUT "$ELASTICSEARCH_URL/_ingest/pipeline/enrich-logs-network_traffic" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic.json
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

# Wait for 10 seconds with the message displayed
sleep 10

# Kill cmatrix process
kill $MATRIX_PID

# Show cursor again and clear screen
tput cnorm
clear




echo "You took the red pill, now we will see how far the rabbit hole goes."
echo 
echo
echo "Starting data ingestion, press CTRL + C to unplug from the Matrix."
echo 
echo
java -jar /root/simple-data-generator/build/libs/simple-data-generator-1.0.0-SNAPSHOT.jar /root/simple-data-generator/secops.yml
