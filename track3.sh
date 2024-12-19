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
