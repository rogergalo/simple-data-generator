#!/bin/bash 
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

curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-nginx" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-nginx.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/nginx-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/nginx-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/timestamp-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/timestamp-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-email" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-email.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/email-filter-rules" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/email-filter-rules.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic-dns" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic-dns.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/logs-network_traffic-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/logs-network_traffic-cleanup.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic.json

echo "Installation completed successfully."
