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

# Add 'ecs@mappings' component templates
curl -X PUT "http://localhost:30920/_component_template/ecs@mappings" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "version": 14,
  "template": {
    "mappings": {
      "dynamic_templates": [
        {
          "ecs_timestamp": {
            "mapping": {
              "ignore_malformed": false,
              "type": "date"
            },
            "match": "@timestamp"
          }
        },
        {
          "ecs_message_match_only_text": {
            "path_match": [
              "message",
              "*.message"
            ],
            "mapping": {
              "type": "match_only_text"
            },
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_non_indexed_keyword": {
            "path_match": [
              "event.original"
            ],
            "mapping": {
              "index": false,
              "type": "keyword",
              "doc_values": false
            }
          }
        },
        {
          "ecs_non_indexed_long": {
            "path_match": [
              "*.x509.public_key_exponent"
            ],
            "mapping": {
              "index": false,
              "type": "long",
              "doc_values": false
            }
          }
        },
        {
          "ecs_ip": {
            "path_match": [
              "ip",
              "*.ip",
              "*_ip"
            ],
            "mapping": {
              "type": "ip"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "ecs_wildcard": {
            "path_match": [
              "*.io.text",
              "*.message_id",
              "*registry.data.strings",
              "*url.path"
            ],
            "mapping": {
              "type": "wildcard"
            },
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_path_match_wildcard_and_match_only_text": {
            "path_match": [
              "*.body.content",
              "*url.full",
              "*url.original"
            ],
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_match_wildcard_and_match_only_text": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "unmatch_mapping_type": "object",
            "match": [
              "*command_line",
              "*stack_trace"
            ]
          }
        },
        {
          "ecs_path_match_keyword_and_match_only_text": {
            "path_match": [
              "*.title",
              "*.executable",
              "*.name",
              "*.working_directory",
              "*.full_name",
              "*file.path",
              "*file.target_path",
              "*os.full",
              "email.subject",
              "vulnerability.description",
              "user_agent.original"
            ],
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_date": {
            "path_match": [
              "*.timestamp",
              "*_timestamp",
              "*.not_after",
              "*.not_before",
              "*.accessed",
              "created",
              "*.created",
              "*.installed",
              "*.creation_date",
              "*.ctime",
              "*.mtime",
              "ingested",
              "*.ingested",
              "*.start",
              "*.end",
              "*.indicator.first_seen",
              "*.indicator.last_seen",
              "*.indicator.modified_at",
              "*threat.enrichments.matched.occurred"
            ],
            "mapping": {
              "type": "date"
            },
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_path_match_float": {
            "path_match": [
              "*.score.*",
              "*_score*"
            ],
            "mapping": {
              "type": "float"
            },
            "path_unmatch": "*.version",
            "unmatch_mapping_type": "object"
          }
        },
        {
          "ecs_usage_double_scaled_float": {
            "path_match": "*.usage",
            "mapping": {
              "scaling_factor": 1000,
              "type": "scaled_float"
            },
            "match_mapping_type": [
              "double",
              "long",
              "string"
            ]
          }
        },
        {
          "ecs_geo_point": {
            "path_match": [
              "*.geo.location"
            ],
            "mapping": {
              "type": "geo_point"
            }
          }
        },
        {
          "ecs_flattened": {
            "path_match": [
              "*structured_data",
              "*exports",
              "*imports"
            ],
            "mapping": {
              "type": "flattened"
            },
            "match_mapping_type": "object"
          }
        },
        {
          "all_strings_to_keywords": {
            "mapping": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        }
      ]
    }
  },
  "_meta": {
    "description": "dynamic mappings based on ECS, installed by x-pack",
    "managed": true
  },
  "deprecated": false
}
EOF

# Add enrich-windows.sysmon_operational index template
curl -X PUT "http://localhost:30920/_index_template/enrich-windows.sysmon_operational" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
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
    }
  }
 },
  "index_patterns": [
    "enrich-windows.sysmon_operational*"
  ],
  "composed_of": [],
  "allow_auto_create": true
}
EOF

# Add enrich-windows.sysmon_operational index data
curl -X POST "http://localhost:30920/enrich-windows.sysmon_operational/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-windows.sysmon_operational.ndjson

# Add enrich-windows.sysmon_operational enrich policy
curl -X PUT "http://localhost:30920/_enrich/policy/enrich-windows.sysmon_operational" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-windows.sysmon_operational",
    "match_field": "wincode",
    "enrich_fields": ["winlog.event_id", "message"]
  }
}
EOF

# Initiate enrich policy for windows
curl -X POST "http://localhost:30920/_enrich/policy/enrich-windows.sysmon_operational/_execute" -u "sdg:changeme"

# Add logs-windows.sysmon_operational ingest pipeline
curl -X PUT "http://localhost:30920/_ingest/pipeline/logs-windows.sysmon_operational" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/logs-windows.sysmon_operational.json

# Add winlogbeat index template
curl -X PUT "http://localhost:30920/_index_template/winlogbeat-8.17" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF' 
{
  "priority": 150,
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "winlogbeat"
        },
        "mapping": {
          "total_fields": {
            "limit": "10000"
          }
        },
        "refresh_interval": "5s",
        "number_of_shards": "1",
        "max_docvalue_fields_search": "200",
        "query": {
          "default_field": [
            "message",
            "tags",
            "agent.ephemeral_id",
            "agent.id",
            "agent.name",
            "agent.type",
            "agent.version",
            "as.organization.name",
            "client.address",
            "client.as.organization.name",
            "client.domain",
            "client.geo.city_name",
            "client.geo.continent_name",
            "client.geo.country_iso_code",
            "client.geo.country_name",
            "client.geo.name",
            "client.geo.region_iso_code",
            "client.geo.region_name",
            "client.mac",
            "client.registered_domain",
            "client.top_level_domain",
            "client.user.domain",
            "client.user.email",
            "client.user.full_name",
            "client.user.group.domain",
            "client.user.group.id",
            "client.user.group.name",
            "client.user.hash",
            "client.user.id",
            "client.user.name",
            "cloud.account.id",
            "cloud.availability_zone",
            "cloud.instance.id",
            "cloud.instance.name",
            "cloud.machine.type",
            "cloud.provider",
            "cloud.region",
            "container.id",
            "container.image.name",
            "container.image.tag",
            "container.name",
            "container.runtime",
            "destination.address",
            "destination.as.organization.name",
            "destination.domain",
            "destination.geo.city_name",
            "destination.geo.continent_name",
            "destination.geo.country_iso_code",
            "destination.geo.country_name",
            "destination.geo.name",
            "destination.geo.region_iso_code",
            "destination.geo.region_name",
            "destination.mac",
            "destination.registered_domain",
            "destination.top_level_domain",
            "destination.user.domain",
            "destination.user.email",
            "destination.user.full_name",
            "destination.user.group.domain",
            "destination.user.group.id",
            "destination.user.group.name",
            "destination.user.hash",
            "destination.user.id",
            "destination.user.name",
            "dns.answers.class",
            "dns.answers.data",
            "dns.answers.name",
            "dns.answers.type",
            "dns.header_flags",
            "dns.id",
            "dns.op_code",
            "dns.question.class",
            "dns.question.name",
            "dns.question.registered_domain",
            "dns.question.subdomain",
            "dns.question.top_level_domain",
            "dns.question.type",
            "dns.response_code",
            "dns.type",
            "ecs.version",
            "error.code",
            "error.id",
            "error.message",
            "error.stack_trace",
            "error.type",
            "event.action",
            "event.category",
            "event.code",
            "event.dataset",
            "event.hash",
            "event.id",
            "event.kind",
            "event.module",
            "event.outcome",
            "event.provider",
            "event.timezone",
            "event.type",
            "file.device",
            "file.directory",
            "file.extension",
            "file.gid",
            "file.group",
            "file.hash.md5",
            "file.hash.sha1",
            "file.hash.sha256",
            "file.hash.sha512",
            "file.inode",
            "file.mode",
            "file.name",
            "file.owner",
            "file.path",
            "file.target_path",
            "file.type",
            "file.uid",
            "geo.city_name",
            "geo.continent_name",
            "geo.country_iso_code",
            "geo.country_name",
            "geo.name",
            "geo.region_iso_code",
            "geo.region_name",
            "group.domain",
            "group.id",
            "group.name",
            "hash.md5",
            "hash.sha1",
            "hash.sha256",
            "hash.sha512",
            "host.architecture",
            "host.geo.city_name",
            "host.geo.continent_name",
            "host.geo.country_iso_code",
            "host.geo.country_name",
            "host.geo.name",
            "host.geo.region_iso_code",
            "host.geo.region_name",
            "host.hostname",
            "host.id",
            "host.mac",
            "host.name",
            "host.os.family",
            "host.os.full",
            "host.os.kernel",
            "host.os.name",
            "host.os.platform",
            "host.os.version",
            "host.type",
            "http.request.body.content",
            "http.request.method",
            "http.request.referrer",
            "http.response.body.content",
            "http.version",
            "log.level",
            "log.logger",
            "log.origin.file.name",
            "log.origin.function",
            "log.syslog.facility.name",
            "log.syslog.severity.name",
            "network.application",
            "network.community_id",
            "network.direction",
            "network.iana_number",
            "network.name",
            "network.protocol",
            "network.transport",
            "network.type",
            "observer.geo.city_name",
            "observer.geo.continent_name",
            "observer.geo.country_iso_code",
            "observer.geo.country_name",
            "observer.geo.name",
            "observer.geo.region_iso_code",
            "observer.geo.region_name",
            "observer.hostname",
            "observer.mac",
            "observer.name",
            "observer.os.family",
            "observer.os.full",
            "observer.os.kernel",
            "observer.os.name",
            "observer.os.platform",
            "observer.os.version",
            "observer.product",
            "observer.serial_number",
            "observer.type",
            "observer.vendor",
            "observer.version",
            "organization.id",
            "organization.name",
            "os.family",
            "os.full",
            "os.kernel",
            "os.name",
            "os.platform",
            "os.version",
            "package.architecture",
            "package.checksum",
            "package.description",
            "package.install_scope",
            "package.license",
            "package.name",
            "package.path",
            "package.version",
            "process.args",
            "process.executable",
            "process.hash.md5",
            "process.hash.sha1",
            "process.hash.sha256",
            "process.hash.sha512",
            "process.name",
            "process.thread.name",
            "process.title",
            "process.working_directory",
            "server.address",
            "server.as.organization.name",
            "server.domain",
            "server.geo.city_name",
            "server.geo.continent_name",
            "server.geo.country_iso_code",
            "server.geo.country_name",
            "server.geo.name",
            "server.geo.region_iso_code",
            "server.geo.region_name",
            "server.mac",
            "server.registered_domain",
            "server.top_level_domain",
            "server.user.domain",
            "server.user.email",
            "server.user.full_name",
            "server.user.group.domain",
            "server.user.group.id",
            "server.user.group.name",
            "server.user.hash",
            "server.user.id",
            "server.user.name",
            "service.ephemeral_id",
            "service.id",
            "service.name",
            "service.node.name",
            "service.state",
            "service.type",
            "service.version",
            "source.address",
            "source.as.organization.name",
            "source.domain",
            "source.geo.city_name",
            "source.geo.continent_name",
            "source.geo.country_iso_code",
            "source.geo.country_name",
            "source.geo.name",
            "source.geo.region_iso_code",
            "source.geo.region_name",
            "source.mac",
            "source.registered_domain",
            "source.top_level_domain",
            "source.user.domain",
            "source.user.email",
            "source.user.full_name",
            "source.user.group.domain",
            "source.user.group.id",
            "source.user.group.name",
            "source.user.hash",
            "source.user.id",
            "source.user.name",
            "threat.framework",
            "threat.tactic.id",
            "threat.tactic.name",
            "threat.tactic.reference",
            "threat.technique.id",
            "threat.technique.name",
            "threat.technique.reference",
            "trace.id",
            "transaction.id",
            "url.domain",
            "url.extension",
            "url.fragment",
            "url.full",
            "url.original",
            "url.password",
            "url.path",
            "url.query",
            "url.registered_domain",
            "url.scheme",
            "url.top_level_domain",
            "url.username",
            "user.domain",
            "user.email",
            "user.full_name",
            "user.group.domain",
            "user.group.id",
            "user.group.name",
            "user.hash",
            "user.id",
            "user.name",
            "user_agent.device.name",
            "user_agent.name",
            "user_agent.original.text",
            "user_agent.original",
            "user_agent.os.family",
            "user_agent.os.full",
            "user_agent.os.kernel",
            "user_agent.os.name",
            "user_agent.os.platform",
            "user_agent.os.version",
            "user_agent.version",
            "cloud.image.id",
            "host.os.build",
            "host.os.codename",
            "kubernetes.pod.name",
            "kubernetes.pod.uid",
            "kubernetes.namespace",
            "kubernetes.node.name",
            "kubernetes.node.hostname",
            "kubernetes.replicaset.name",
            "kubernetes.deployment.name",
            "kubernetes.statefulset.name",
            "kubernetes.container.name",
            "process.owner.id",
            "process.owner.name.text",
            "process.owner.name",
            "jolokia.agent.version",
            "jolokia.agent.id",
            "jolokia.server.product",
            "jolokia.server.version",
            "jolokia.server.vendor",
            "jolokia.url",
            "fields.*"
          ]
        },
        "default_pipeline": "logs-windows.sysmon_operational",
        "analysis": {
          "analyzer": {
            "winlogbeat_powershell_script_analyzer": {
              "pattern": "[\\W&&[^-]]+",
              "type": "pattern"
            }
          }
        },
        "number_of_replicas": "0"
      }
    },
    "mappings": {
      "_meta": {
        "beat": "winlogbeat",
        "version": "8.17.0"
      },
      "dynamic_templates": [
        {
          "labels": {
            "path_match": "labels.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "container.labels": {
            "path_match": "container.labels.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "fields": {
            "path_match": "fields.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "docker.container.labels": {
            "path_match": "docker.container.labels.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "kubernetes.labels.*": {
            "path_match": "kubernetes.labels.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "*"
          }
        },
        {
          "kubernetes.annotations.*": {
            "path_match": "kubernetes.annotations.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "*"
          }
        },
        {
          "kubernetes.selectors.*": {
            "path_match": "kubernetes.selectors.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "*"
          }
        },
        {
          "winlog.event_data": {
            "path_match": "winlog.event_data.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "winlog.user_data": {
            "path_match": "winlog.user_data.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "strings_as_keyword": {
            "mapping": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        }
      ],
      "date_detection": false,
      "properties": {
        "container": {
          "properties": {
            "image": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "tag": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "disk": {
              "properties": {
                "read": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                },
                "write": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "memory": {
              "properties": {
                "usage": {
                  "scaling_factor": 1000,
                  "type": "scaled_float"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "runtime": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "cpu": {
              "properties": {
                "usage": {
                  "scaling_factor": 1000,
                  "type": "scaled_float"
                }
              }
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "labels": {
              "type": "object"
            },
            "network": {
              "properties": {
                "ingress": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                },
                "egress": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                }
              }
            }
          }
        },
        "kubernetes": {
          "properties": {
            "container": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "node": {
              "properties": {
                "hostname": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "pod": {
              "properties": {
                "uid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ip": {
                  "type": "ip"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "statefulset": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "namespace": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "annotations": {
              "properties": {
                "*": {
                  "type": "object"
                }
              }
            },
            "replicaset": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "selectors": {
              "properties": {
                "*": {
                  "type": "object"
                }
              }
            },
            "labels": {
              "properties": {
                "*": {
                  "type": "object"
                }
              }
            },
            "deployment": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "faas": {
          "properties": {
            "execution": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "coldstart": {
              "type": "boolean"
            },
            "trigger": {
              "type": "nested",
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "request_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "agent": {
          "properties": {
            "hostname": {
              "path": "agent.name",
              "type": "alias"
            },
            "build": {
              "properties": {
                "original": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ephemeral_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "sysmon": {
          "properties": {
            "file": {
              "properties": {
                "archived": {
                  "type": "boolean"
                },
                "is_executable": {
                  "type": "boolean"
                }
              }
            },
            "dns": {
              "properties": {
                "status": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "source": {
          "properties": {
            "nat": {
              "properties": {
                "port": {
                  "type": "long"
                },
                "ip": {
                  "type": "ip"
                }
              }
            },
            "address": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "top_level_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "packets": {
              "type": "long"
            },
            "geo": {
              "properties": {
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "as": {
              "properties": {
                "number": {
                  "type": "long"
                },
                "organization": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    }
                  }
                }
              }
            },
            "registered_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "subdomain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "user": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "cloud": {
          "properties": {
            "availability_zone": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "image": {
              "properties": {
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "instance": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "provider": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "service": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "machine": {
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "origin": {
              "properties": {
                "availability_zone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "instance": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "provider": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "machine": {
                  "properties": {
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "service": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "project": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "region": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "account": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "project": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "region": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "account": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "target": {
              "properties": {
                "availability_zone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "instance": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "provider": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "machine": {
                  "properties": {
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "service": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "project": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "region": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "account": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "observer": {
          "properties": {
            "product": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "os": {
              "properties": {
                "kernel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "family": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "platform": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "full": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                }
              }
            },
            "ip": {
              "type": "ip"
            },
            "serial_number": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "egress": {
              "type": "object",
              "properties": {
                "vlan": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "zone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "interface": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "alias": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "geo": {
              "properties": {
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "ingress": {
              "type": "object",
              "properties": {
                "vlan": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "zone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "interface": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "alias": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "hostname": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "vendor": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "ecs": {
          "properties": {
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "timeseries": {
          "properties": {
            "instance": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "code_signature": {
          "properties": {
            "valid": {
              "type": "boolean"
            },
            "digest_algorithm": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "signing_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "trusted": {
              "type": "boolean"
            },
            "subject_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "exists": {
              "type": "boolean"
            },
            "team_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "status": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "timestamp": {
              "type": "date"
            }
          }
        },
        "powershell": {
          "properties": {
            "sequence": {
              "type": "long"
            },
            "process": {
              "properties": {
                "executable_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "total": {
              "type": "long"
            },
            "connected_user": {
              "properties": {
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "file": {
              "properties": {
                "script_block_text": {
                  "search_analyzer": "winlogbeat_powershell_script_analyzer",
                  "norms": false,
                  "analyzer": "winlogbeat_powershell_script_analyzer",
                  "type": "text"
                },
                "script_block_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "engine": {
              "properties": {
                "previous_state": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "new_state": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "provider": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "new_state": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "runspace_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "pipeline_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "command": {
              "properties": {
                "path": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "invocation_details": {
                  "properties": {
                    "related_command": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "value": {
                      "norms": false,
                      "type": "text"
                    }
                  }
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "value": {
                  "norms": false,
                  "type": "text"
                }
              }
            }
          }
        },
        "host": {
          "properties": {
            "os": {
              "properties": {
                "build": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "kernel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "codename": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "family": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "platform": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "full": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                }
              }
            },
            "ip": {
              "type": "ip"
            },
            "cpu": {
              "properties": {
                "usage": {
                  "scaling_factor": 1000,
                  "type": "scaled_float"
                }
              }
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "network": {
              "properties": {
                "ingress": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    },
                    "packets": {
                      "type": "long"
                    }
                  }
                },
                "egress": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    },
                    "packets": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "uptime": {
              "type": "long"
            },
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "disk": {
              "properties": {
                "read": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                },
                "write": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "hostname": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "containerized": {
              "type": "boolean"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "architecture": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "elf": {
          "properties": {
            "imports": {
              "type": "flattened"
            },
            "shared_libraries": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "exports": {
              "type": "flattened"
            },
            "byte_order": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "cpu_type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "header": {
              "properties": {
                "object_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "data": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "os_abi": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "entrypoint": {
                  "type": "long"
                },
                "abi_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "class": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "creation_date": {
              "type": "date"
            },
            "telfhash": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "sections": {
              "type": "nested",
              "properties": {
                "chi2": {
                  "type": "long"
                },
                "virtual_address": {
                  "type": "long"
                },
                "entropy": {
                  "type": "long"
                },
                "physical_offset": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "flags": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "physical_size": {
                  "type": "long"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "virtual_size": {
                  "type": "long"
                }
              }
            },
            "architecture": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "segments": {
              "type": "nested",
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sections": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "group": {
          "properties": {
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "package": {
          "properties": {
            "installed": {
              "type": "date"
            },
            "build_version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "description": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "reference": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "license": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "path": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "install_scope": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "size": {
              "type": "long"
            },
            "checksum": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "architecture": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "dns": {
          "properties": {
            "op_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "resolved_ip": {
              "type": "ip"
            },
            "response_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "question": {
              "properties": {
                "registered_domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "top_level_domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "subdomain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "class": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "answers": {
              "type": "object",
              "properties": {
                "data": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "class": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ttl": {
                  "type": "long"
                }
              }
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "header_flags": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "vulnerability": {
          "properties": {
            "reference": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "severity": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "score": {
              "properties": {
                "environmental": {
                  "type": "float"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "temporal": {
                  "type": "float"
                },
                "base": {
                  "type": "float"
                }
              }
            },
            "report_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "scanner": {
              "properties": {
                "vendor": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "description": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "enumeration": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "category": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "classification": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "tags": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "labels": {
          "type": "object"
        },
        "x509": {
          "properties": {
            "not_after": {
              "type": "date"
            },
            "public_key_exponent": {
              "index": false,
              "type": "long",
              "doc_values": false
            },
            "not_before": {
              "type": "date"
            },
            "subject": {
              "properties": {
                "country": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "state_or_province": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "organization": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "distinguished_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "locality": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "common_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "organizational_unit": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "public_key_curve": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "public_key_algorithm": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "signature_algorithm": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "public_key_size": {
              "type": "long"
            },
            "version_number": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "serial_number": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "alternative_names": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "issuer": {
              "properties": {
                "state_or_province": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "organization": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "distinguished_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "locality": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "common_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "organizational_unit": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "orchestrator": {
          "properties": {
            "cluster": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "url": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "resource": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "organization": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "namespace": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "api_version": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "as": {
          "properties": {
            "number": {
              "type": "long"
            },
            "organization": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                }
              }
            }
          }
        },
        "http": {
          "properties": {
            "request": {
              "properties": {
                "referrer": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "method": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "mime_type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "bytes": {
                  "type": "long"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "body": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    },
                    "content": {
                      "type": "wildcard",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    }
                  }
                }
              }
            },
            "response": {
              "properties": {
                "status_code": {
                  "type": "long"
                },
                "mime_type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "bytes": {
                  "type": "long"
                },
                "body": {
                  "properties": {
                    "bytes": {
                      "type": "long"
                    },
                    "content": {
                      "type": "wildcard",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    }
                  }
                }
              }
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "fields": {
          "type": "object"
        },
        "hash": {
          "properties": {
            "sha1": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "sha256": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "sha512": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ssdeep": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "md5": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "server": {
          "properties": {
            "nat": {
              "properties": {
                "port": {
                  "type": "long"
                },
                "ip": {
                  "type": "ip"
                }
              }
            },
            "address": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "top_level_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "packets": {
              "type": "long"
            },
            "geo": {
              "properties": {
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "registered_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "as": {
              "properties": {
                "number": {
                  "type": "long"
                },
                "organization": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      },
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "subdomain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "user": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "log": {
          "properties": {
            "file": {
              "properties": {
                "path": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "level": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "logger": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "origin": {
              "properties": {
                "file": {
                  "properties": {
                    "line": {
                      "type": "long"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "function": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "syslog": {
              "type": "object",
              "properties": {
                "severity": {
                  "properties": {
                    "code": {
                      "type": "long"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "priority": {
                  "type": "long"
                },
                "facility": {
                  "properties": {
                    "code": {
                      "type": "long"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "destination": {
          "properties": {
            "nat": {
              "properties": {
                "port": {
                  "type": "long"
                },
                "ip": {
                  "type": "ip"
                }
              }
            },
            "address": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "top_level_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "packets": {
              "type": "long"
            },
            "geo": {
              "properties": {
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "registered_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "as": {
              "properties": {
                "number": {
                  "type": "long"
                },
                "organization": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    }
                  }
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "subdomain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "user": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "rule": {
          "properties": {
            "reference": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "license": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "author": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ruleset": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "description": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "category": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "uuid": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "interface": {
          "properties": {
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "alias": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "error": {
          "properties": {
            "code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "stack_trace": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "message": {
              "type": "match_only_text"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "docker": {
          "properties": {
            "container": {
              "properties": {
                "labels": {
                  "type": "object"
                }
              }
            }
          }
        },
        "network": {
          "properties": {
            "transport": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "inner": {
              "type": "object",
              "properties": {
                "vlan": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "packets": {
              "type": "long"
            },
            "community_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "forwarded_ip": {
              "type": "ip"
            },
            "protocol": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "vlan": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "application": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "bytes": {
              "type": "long"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "iana_number": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "direction": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "geo": {
          "properties": {
            "continent_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "region_iso_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "city_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "country_iso_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "timezone": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "country_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "continent_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "location": {
              "type": "geo_point"
            },
            "region_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "postal_code": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "trace": {
          "properties": {
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "file": {
          "properties": {
            "extension": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "gid": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "drive_letter": {
              "ignore_above": 1,
              "type": "keyword"
            },
            "accessed": {
              "type": "date"
            },
            "mtime": {
              "type": "date"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "directory": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "mode": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "inode": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "path": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "uid": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "code_signature": {
              "properties": {
                "valid": {
                  "type": "boolean"
                },
                "digest_algorithm": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "signing_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "trusted": {
                  "type": "boolean"
                },
                "subject_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "exists": {
                  "type": "boolean"
                },
                "team_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timestamp": {
                  "type": "date"
                },
                "status": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "fork_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ctime": {
              "type": "date"
            },
            "elf": {
              "properties": {
                "imports": {
                  "type": "flattened"
                },
                "shared_libraries": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "exports": {
                  "type": "flattened"
                },
                "byte_order": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "cpu_type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "header": {
                  "properties": {
                    "object_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "data": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "entrypoint": {
                      "type": "long"
                    },
                    "os_abi": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "abi_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "class": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "creation_date": {
                  "type": "date"
                },
                "telfhash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sections": {
                  "type": "nested",
                  "properties": {
                    "chi2": {
                      "type": "long"
                    },
                    "virtual_address": {
                      "type": "long"
                    },
                    "entropy": {
                      "type": "long"
                    },
                    "physical_offset": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "flags": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "physical_size": {
                      "type": "long"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "virtual_size": {
                      "type": "long"
                    }
                  }
                },
                "segments": {
                  "type": "nested",
                  "properties": {
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sections": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "group": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "owner": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "created": {
              "type": "date"
            },
            "target_path": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "x509": {
              "properties": {
                "not_after": {
                  "type": "date"
                },
                "public_key_exponent": {
                  "index": false,
                  "type": "long",
                  "doc_values": false
                },
                "not_before": {
                  "type": "date"
                },
                "subject": {
                  "properties": {
                    "state_or_province": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "country": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "organization": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "locality": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "distinguished_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "common_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "organizational_unit": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "public_key_algorithm": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "public_key_curve": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "signature_algorithm": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version_number": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "public_key_size": {
                  "type": "long"
                },
                "serial_number": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "alternative_names": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "issuer": {
                  "properties": {
                    "state_or_province": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "country": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "organization": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "distinguished_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "locality": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "common_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "organizational_unit": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "size": {
              "type": "long"
            },
            "pe": {
              "properties": {
                "file_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "product": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "imphash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "description": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "original_file_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "company": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "mime_type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "attributes": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "device": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "hash": {
              "properties": {
                "sha1": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha256": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha512": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ssdeep": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "md5": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "vlan": {
          "properties": {
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "related": {
          "properties": {
            "hosts": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "user": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "hash": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "client": {
          "properties": {
            "nat": {
              "properties": {
                "port": {
                  "type": "long"
                },
                "ip": {
                  "type": "ip"
                }
              }
            },
            "address": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "top_level_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "packets": {
              "type": "long"
            },
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "continent_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "postal_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "registered_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "as": {
              "properties": {
                "number": {
                  "type": "long"
                },
                "organization": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      },
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "subdomain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "user": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "event": {
          "properties": {
            "reason": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "timezone": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "agent_id_status": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "duration": {
              "type": "long"
            },
            "reference": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ingested": {
              "type": "date"
            },
            "provider": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "action": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "end": {
              "type": "date"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "outcome": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "severity": {
              "type": "long"
            },
            "original": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "risk_score": {
              "type": "float"
            },
            "kind": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "created": {
              "type": "date"
            },
            "module": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "start": {
              "type": "date"
            },
            "url": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "sequence": {
              "type": "long"
            },
            "risk_score_norm": {
              "type": "float"
            },
            "category": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "dataset": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "hash": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "user_agent": {
          "properties": {
            "original": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "os": {
              "properties": {
                "kernel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "family": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "platform": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "full": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "device": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "jolokia": {
          "properties": {
            "server": {
              "properties": {
                "product": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "vendor": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "agent": {
              "properties": {
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "secured": {
              "type": "boolean"
            },
            "url": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "registry": {
          "properties": {
            "hive": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "path": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "data": {
              "properties": {
                "strings": {
                  "type": "wildcard"
                },
                "bytes": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "value": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "key": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "process": {
          "properties": {
            "owner": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "norms": false,
                      "type": "text"
                    }
                  },
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "parent": {
              "properties": {
                "pgid": {
                  "type": "long"
                },
                "start": {
                  "type": "date"
                },
                "pid": {
                  "type": "long"
                },
                "working_directory": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "thread": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "type": "long"
                    }
                  }
                },
                "title": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "entity_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "executable": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "uptime": {
                  "type": "long"
                },
                "args": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "code_signature": {
                  "properties": {
                    "valid": {
                      "type": "boolean"
                    },
                    "digest_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "signing_id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "trusted": {
                      "type": "boolean"
                    },
                    "subject_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "exists": {
                      "type": "boolean"
                    },
                    "team_id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "status": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "timestamp": {
                      "type": "date"
                    }
                  }
                },
                "pe": {
                  "properties": {
                    "file_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "product": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "imphash": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "description": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "company": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "original_file_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "architecture": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "exit_code": {
                  "type": "long"
                },
                "end": {
                  "type": "date"
                },
                "args_count": {
                  "type": "long"
                },
                "hash": {
                  "properties": {
                    "sha1": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sha256": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sha512": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "ssdeep": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "md5": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "elf": {
                  "properties": {
                    "imports": {
                      "type": "flattened"
                    },
                    "shared_libraries": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "byte_order": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "exports": {
                      "type": "flattened"
                    },
                    "cpu_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "header": {
                      "properties": {
                        "object_version": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "data": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "entrypoint": {
                          "type": "long"
                        },
                        "os_abi": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "abi_version": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "version": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "class": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "creation_date": {
                      "type": "date"
                    },
                    "telfhash": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sections": {
                      "type": "nested",
                      "properties": {
                        "chi2": {
                          "type": "long"
                        },
                        "virtual_address": {
                          "type": "long"
                        },
                        "entropy": {
                          "type": "long"
                        },
                        "physical_offset": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "flags": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "physical_size": {
                          "type": "long"
                        },
                        "type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "virtual_size": {
                          "type": "long"
                        }
                      }
                    },
                    "segments": {
                      "type": "nested",
                      "properties": {
                        "type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "sections": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "architecture": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "command_line": {
                  "type": "wildcard",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                }
              }
            },
            "pgid": {
              "type": "long"
            },
            "start": {
              "type": "date"
            },
            "pid": {
              "type": "long"
            },
            "working_directory": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "thread": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "type": "long"
                }
              }
            },
            "title": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "entity_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "executable": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "uptime": {
              "type": "long"
            },
            "args": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "code_signature": {
              "properties": {
                "valid": {
                  "type": "boolean"
                },
                "digest_algorithm": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "signing_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "trusted": {
                  "type": "boolean"
                },
                "subject_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "exists": {
                  "type": "boolean"
                },
                "team_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "status": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timestamp": {
                  "type": "date"
                }
              }
            },
            "pe": {
              "properties": {
                "file_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "product": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "imphash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "description": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "company": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "original_file_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "exit_code": {
              "type": "long"
            },
            "end": {
              "type": "date"
            },
            "args_count": {
              "type": "long"
            },
            "command_line": {
              "type": "wildcard",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "elf": {
              "properties": {
                "imports": {
                  "type": "flattened"
                },
                "shared_libraries": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "byte_order": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "exports": {
                  "type": "flattened"
                },
                "cpu_type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "header": {
                  "properties": {
                    "object_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "data": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "entrypoint": {
                      "type": "long"
                    },
                    "os_abi": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "abi_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "class": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "creation_date": {
                  "type": "date"
                },
                "sections": {
                  "type": "nested",
                  "properties": {
                    "chi2": {
                      "type": "long"
                    },
                    "virtual_address": {
                      "type": "long"
                    },
                    "entropy": {
                      "type": "long"
                    },
                    "physical_offset": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "flags": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "physical_size": {
                      "type": "long"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "virtual_size": {
                      "type": "long"
                    }
                  }
                },
                "telfhash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "segments": {
                  "type": "nested",
                  "properties": {
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sections": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "hash": {
              "properties": {
                "sha1": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha256": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha512": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ssdeep": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "md5": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "winlog": {
          "properties": {
            "related_activity_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "computer_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "trustAttribute": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "process": {
              "properties": {
                "pid": {
                  "type": "long"
                },
                "thread": {
                  "properties": {
                    "id": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "keywords": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "logon": {
              "properties": {
                "failure": {
                  "properties": {
                    "reason": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sub_status": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "status": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "computerObject": {
              "properties": {
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "channel": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "event_data": {
              "properties": {
                "SignatureStatus": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ProcessName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DeviceTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LogonGuid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Query": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Configuration": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "OriginalFileName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "BootMode": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Product": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "StartAddress": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetLogonGuid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "FileVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "CallTrace": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "StopTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Status": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "GrantedAccess": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "CorruptionActionState": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "KeyLength": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PreviousCreationUtcTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetInfo": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ServiceVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "SubjectUserSid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetUserSid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PerformanceImplementation": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Group": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NewThreadId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Description": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ShutdownActionType": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ProcessPid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DwordVal": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DeviceVersionMajor": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ScriptBlockText": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TransmittedServices": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MaximumPerformancePercent": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NewTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "FinalStatus": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "IdleStateCount": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Path": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MajorVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "SchemaVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TokenElevationType": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MinorVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "SubjectLogonId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ProcessPath": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "IdleImplementation": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "QfeVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DeviceVersionMinor": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "OldTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "IpAddress": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DeviceName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Company": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PuaPolicyId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "EventType": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "IntegrityLevel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LastShutdownGood": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "IpPort": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DriverNameLength": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LmPackageName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "UserSid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LastBootGood": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PuaCount": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetProcessGUID": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Signed": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "StartTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ShutdownEventCode": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NewProcessName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "FailureNameLength": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetProcessId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ServiceName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "State": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PreviousTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "StartFunction": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "BootType": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetUserName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MemberName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ClientInfo": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Binary": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ImpersonationLevel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Detail": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TerminalSessionId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MemberSid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DriverName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DeviceNameLength": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "OldSchemeGuid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Operation": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "CreationUtcTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ShutdownReason": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Reason": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetServerName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Number": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "BuildVersion": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "SubjectDomainName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetImage": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MinimumPerformancePercent": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetDomainName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LogonProcessName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LogonId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TSId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "PrivilegeList": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param7": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param8": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param5": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param6": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "DriveName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NewProcessId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "EventNamespace": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "LogonType": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ExtraInfo": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "StartModule": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param3": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param4": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param1": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "param2": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "TargetLogonId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Workstation": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "SubjectUserName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "FailureName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Signature": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NewSchemeGuid": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "MinimumThrottlePercent": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ProcessId": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "EntryCount": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "BitlockerUserInputTime": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "NominalFrequency": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "AuthenticationPackageName": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "Session": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "user_data": {
              "type": "object"
            },
            "opcode": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "type": "long"
            },
            "record_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "task": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "event_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "provider_guid": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "activity_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "trustDirection": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "time_created": {
              "type": "date"
            },
            "trustType": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "api": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "provider_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "user": {
              "properties": {
                "identifier": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "os": {
          "properties": {
            "kernel": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "family": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "platform": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "full": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            }
          }
        },
        "dll": {
          "properties": {
            "path": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "code_signature": {
              "properties": {
                "valid": {
                  "type": "boolean"
                },
                "digest_algorithm": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "signing_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "trusted": {
                  "type": "boolean"
                },
                "subject_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "exists": {
                  "type": "boolean"
                },
                "team_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "status": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timestamp": {
                  "type": "date"
                }
              }
            },
            "pe": {
              "properties": {
                "file_version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "product": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "imphash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "description": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "company": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "original_file_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "hash": {
              "properties": {
                "sha1": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha256": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sha512": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ssdeep": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "md5": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "message": {
          "type": "match_only_text"
        },
        "url": {
          "properties": {
            "extension": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "original": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "scheme": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "top_level_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "query": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "path": {
              "type": "wildcard"
            },
            "registered_domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "password": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "fragment": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "port": {
              "type": "long"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "subdomain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "full": {
              "type": "wildcard",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "username": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "@timestamp": {
          "type": "date"
        },
        "pe": {
          "properties": {
            "file_version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "product": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "imphash": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "description": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "original_file_name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "company": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "architecture": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "data_stream": {
          "properties": {
            "namespace": {
              "type": "constant_keyword"
            },
            "type": {
              "type": "constant_keyword"
            },
            "dataset": {
              "type": "constant_keyword"
            }
          }
        },
        "service": {
          "properties": {
            "node": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "environment": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "address": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "origin": {
              "properties": {
                "node": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "environment": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "address": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "state": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ephemeral_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "state": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ephemeral_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "target": {
              "properties": {
                "node": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "environment": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "address": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "state": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ephemeral_id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "organization": {
          "properties": {
            "name": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "tls": {
          "properties": {
            "cipher": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "established": {
              "type": "boolean"
            },
            "server": {
              "properties": {
                "not_after": {
                  "type": "date"
                },
                "x509": {
                  "properties": {
                    "not_after": {
                      "type": "date"
                    },
                    "public_key_exponent": {
                      "index": false,
                      "type": "long",
                      "doc_values": false
                    },
                    "not_before": {
                      "type": "date"
                    },
                    "subject": {
                      "properties": {
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "public_key_curve": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "signature_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_size": {
                      "type": "long"
                    },
                    "version_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "serial_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "alternative_names": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "issuer": {
                      "properties": {
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    }
                  }
                },
                "ja3s": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "not_before": {
                  "type": "date"
                },
                "subject": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "certificate": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "certificate_chain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "properties": {
                    "sha1": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sha256": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "md5": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "issuer": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "curve": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "client": {
              "properties": {
                "not_after": {
                  "type": "date"
                },
                "server_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "x509": {
                  "properties": {
                    "not_after": {
                      "type": "date"
                    },
                    "public_key_exponent": {
                      "index": false,
                      "type": "long",
                      "doc_values": false
                    },
                    "subject": {
                      "properties": {
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "not_before": {
                      "type": "date"
                    },
                    "public_key_curve": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "signature_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "version_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "serial_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_size": {
                      "type": "long"
                    },
                    "alternative_names": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "issuer": {
                      "properties": {
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    }
                  }
                },
                "subject": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "not_before": {
                  "type": "date"
                },
                "supported_ciphers": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "certificate": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ja3": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "certificate_chain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "properties": {
                    "sha1": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sha256": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "md5": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "issuer": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "next_protocol": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "resumed": {
              "type": "boolean"
            },
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "version_protocol": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "threat": {
          "properties": {
            "indicator": {
              "properties": {
                "registry": {
                  "properties": {
                    "hive": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "path": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "data": {
                      "properties": {
                        "strings": {
                          "type": "wildcard"
                        },
                        "bytes": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "value": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "key": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "first_seen": {
                  "type": "date"
                },
                "last_seen": {
                  "type": "date"
                },
                "confidence": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ip": {
                  "type": "ip"
                },
                "description": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "sightings": {
                  "type": "long"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "url": {
                  "properties": {
                    "extension": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "original": {
                      "type": "wildcard",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    },
                    "scheme": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "top_level_domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "query": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "path": {
                      "type": "wildcard"
                    },
                    "registered_domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "fragment": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "password": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "port": {
                      "type": "long"
                    },
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "subdomain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "full": {
                      "type": "wildcard",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    },
                    "username": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "scanner_stats": {
                  "type": "long"
                },
                "geo": {
                  "properties": {
                    "continent_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "region_iso_code": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "city_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "country_iso_code": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "timezone": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "country_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "continent_code": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "location": {
                      "type": "geo_point"
                    },
                    "region_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "postal_code": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "reference": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "x509": {
                  "properties": {
                    "not_after": {
                      "type": "date"
                    },
                    "public_key_exponent": {
                      "index": false,
                      "type": "long",
                      "doc_values": false
                    },
                    "subject": {
                      "properties": {
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "not_before": {
                      "type": "date"
                    },
                    "public_key_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_curve": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "signature_algorithm": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "public_key_size": {
                      "type": "long"
                    },
                    "version_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "serial_number": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "alternative_names": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "issuer": {
                      "properties": {
                        "country": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "state_or_province": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organization": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "distinguished_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "locality": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "common_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "organizational_unit": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    }
                  }
                },
                "as": {
                  "properties": {
                    "number": {
                      "type": "long"
                    },
                    "organization": {
                      "properties": {
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword",
                          "fields": {
                            "text": {
                              "type": "match_only_text"
                            }
                          }
                        }
                      }
                    }
                  }
                },
                "file": {
                  "properties": {
                    "extension": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "gid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "drive_letter": {
                      "ignore_above": 1,
                      "type": "keyword"
                    },
                    "accessed": {
                      "type": "date"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "mtime": {
                      "type": "date"
                    },
                    "directory": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "inode": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "mode": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "path": {
                      "ignore_above": 1024,
                      "type": "keyword",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    },
                    "uid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "code_signature": {
                      "properties": {
                        "valid": {
                          "type": "boolean"
                        },
                        "digest_algorithm": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "signing_id": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "trusted": {
                          "type": "boolean"
                        },
                        "subject_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "exists": {
                          "type": "boolean"
                        },
                        "team_id": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "status": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "timestamp": {
                          "type": "date"
                        }
                      }
                    },
                    "ctime": {
                      "type": "date"
                    },
                    "fork_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "elf": {
                      "properties": {
                        "imports": {
                          "type": "flattened"
                        },
                        "shared_libraries": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "exports": {
                          "type": "flattened"
                        },
                        "byte_order": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "cpu_type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "header": {
                          "properties": {
                            "object_version": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "data": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "entrypoint": {
                              "type": "long"
                            },
                            "os_abi": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "abi_version": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "type": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "version": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "class": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "creation_date": {
                          "type": "date"
                        },
                        "telfhash": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "sections": {
                          "type": "nested",
                          "properties": {
                            "chi2": {
                              "type": "long"
                            },
                            "virtual_address": {
                              "type": "long"
                            },
                            "entropy": {
                              "type": "long"
                            },
                            "physical_offset": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "flags": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "physical_size": {
                              "type": "long"
                            },
                            "type": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "virtual_size": {
                              "type": "long"
                            }
                          }
                        },
                        "architecture": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "segments": {
                          "type": "nested",
                          "properties": {
                            "type": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "sections": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        }
                      }
                    },
                    "group": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "owner": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "created": {
                      "type": "date"
                    },
                    "target_path": {
                      "ignore_above": 1024,
                      "type": "keyword",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    },
                    "x509": {
                      "properties": {
                        "not_after": {
                          "type": "date"
                        },
                        "public_key_exponent": {
                          "index": false,
                          "type": "long",
                          "doc_values": false
                        },
                        "not_before": {
                          "type": "date"
                        },
                        "subject": {
                          "properties": {
                            "country": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "state_or_province": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organization": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "distinguished_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "locality": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "common_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organizational_unit": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "public_key_algorithm": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "public_key_curve": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "signature_algorithm": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "public_key_size": {
                          "type": "long"
                        },
                        "version_number": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "serial_number": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "alternative_names": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "issuer": {
                          "properties": {
                            "state_or_province": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "country": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organization": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "distinguished_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "locality": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "common_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organizational_unit": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        }
                      }
                    },
                    "size": {
                      "type": "long"
                    },
                    "pe": {
                      "properties": {
                        "file_version": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "product": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "imphash": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "description": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "original_file_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "company": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "architecture": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "mime_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "attributes": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "device": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "hash": {
                      "properties": {
                        "sha1": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "sha256": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "sha512": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "ssdeep": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "md5": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    }
                  }
                },
                "marking": {
                  "properties": {
                    "tlp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "port": {
                  "type": "long"
                },
                "provider": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "modified_at": {
                  "type": "date"
                },
                "email": {
                  "properties": {
                    "address": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "framework": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "software": {
              "properties": {
                "reference": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "alias": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "platforms": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "technique": {
              "properties": {
                "reference": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "subtechnique": {
                  "properties": {
                    "reference": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword",
                      "fields": {
                        "text": {
                          "type": "match_only_text"
                        }
                      }
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "enrichments": {
              "type": "nested",
              "properties": {
                "indicator": {
                  "type": "object",
                  "properties": {
                    "registry": {
                      "properties": {
                        "hive": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "path": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "data": {
                          "properties": {
                            "strings": {
                              "type": "wildcard"
                            },
                            "bytes": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "type": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "value": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "key": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "first_seen": {
                      "type": "date"
                    },
                    "last_seen": {
                      "type": "date"
                    },
                    "ip": {
                      "type": "ip"
                    },
                    "confidence": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sightings": {
                      "type": "long"
                    },
                    "description": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "url": {
                      "properties": {
                        "extension": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "original": {
                          "type": "wildcard",
                          "fields": {
                            "text": {
                              "type": "match_only_text"
                            }
                          }
                        },
                        "scheme": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "top_level_domain": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "query": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "path": {
                          "type": "wildcard"
                        },
                        "registered_domain": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "fragment": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "password": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "port": {
                          "type": "long"
                        },
                        "domain": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "subdomain": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "full": {
                          "type": "wildcard",
                          "fields": {
                            "text": {
                              "type": "match_only_text"
                            }
                          }
                        },
                        "username": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "scanner_stats": {
                      "type": "long"
                    },
                    "reference": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "geo": {
                      "properties": {
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "timezone": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "postal_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "x509": {
                      "properties": {
                        "not_after": {
                          "type": "date"
                        },
                        "public_key_exponent": {
                          "index": false,
                          "type": "long",
                          "doc_values": false
                        },
                        "subject": {
                          "properties": {
                            "state_or_province": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "country": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organization": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "locality": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "distinguished_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "common_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organizational_unit": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "not_before": {
                          "type": "date"
                        },
                        "public_key_algorithm": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "public_key_curve": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "signature_algorithm": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "public_key_size": {
                          "type": "long"
                        },
                        "serial_number": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "version_number": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "alternative_names": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "issuer": {
                          "properties": {
                            "country": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "state_or_province": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organization": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "distinguished_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "locality": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "common_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "organizational_unit": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        }
                      }
                    },
                    "as": {
                      "properties": {
                        "number": {
                          "type": "long"
                        },
                        "organization": {
                          "properties": {
                            "name": {
                              "ignore_above": 1024,
                              "type": "keyword",
                              "fields": {
                                "text": {
                                  "type": "match_only_text"
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    "marking": {
                      "properties": {
                        "tlp": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "file": {
                      "properties": {
                        "extension": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "gid": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "drive_letter": {
                          "ignore_above": 1,
                          "type": "keyword"
                        },
                        "mtime": {
                          "type": "date"
                        },
                        "accessed": {
                          "type": "date"
                        },
                        "type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "directory": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "inode": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "mode": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "path": {
                          "ignore_above": 1024,
                          "type": "keyword",
                          "fields": {
                            "text": {
                              "type": "match_only_text"
                            }
                          }
                        },
                        "uid": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "code_signature": {
                          "properties": {
                            "valid": {
                              "type": "boolean"
                            },
                            "digest_algorithm": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "signing_id": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "trusted": {
                              "type": "boolean"
                            },
                            "subject_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "exists": {
                              "type": "boolean"
                            },
                            "team_id": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "status": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "timestamp": {
                              "type": "date"
                            }
                          }
                        },
                        "ctime": {
                          "type": "date"
                        },
                        "fork_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "elf": {
                          "properties": {
                            "imports": {
                              "type": "flattened"
                            },
                            "shared_libraries": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "byte_order": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "exports": {
                              "type": "flattened"
                            },
                            "cpu_type": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "header": {
                              "properties": {
                                "object_version": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "data": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "entrypoint": {
                                  "type": "long"
                                },
                                "os_abi": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "abi_version": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "type": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "class": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "version": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                }
                              }
                            },
                            "creation_date": {
                              "type": "date"
                            },
                            "sections": {
                              "type": "nested",
                              "properties": {
                                "chi2": {
                                  "type": "long"
                                },
                                "virtual_address": {
                                  "type": "long"
                                },
                                "entropy": {
                                  "type": "long"
                                },
                                "physical_offset": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "name": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "flags": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "physical_size": {
                                  "type": "long"
                                },
                                "type": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "virtual_size": {
                                  "type": "long"
                                }
                              }
                            },
                            "telfhash": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "segments": {
                              "type": "nested",
                              "properties": {
                                "type": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "sections": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                }
                              }
                            },
                            "architecture": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "group": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "owner": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "created": {
                          "type": "date"
                        },
                        "target_path": {
                          "ignore_above": 1024,
                          "type": "keyword",
                          "fields": {
                            "text": {
                              "type": "match_only_text"
                            }
                          }
                        },
                        "x509": {
                          "properties": {
                            "not_after": {
                              "type": "date"
                            },
                            "public_key_exponent": {
                              "index": false,
                              "type": "long",
                              "doc_values": false
                            },
                            "subject": {
                              "properties": {
                                "country": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "state_or_province": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "organization": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "distinguished_name": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "locality": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "common_name": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "organizational_unit": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                }
                              }
                            },
                            "not_before": {
                              "type": "date"
                            },
                            "public_key_algorithm": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "public_key_curve": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "signature_algorithm": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "serial_number": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "version_number": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "public_key_size": {
                              "type": "long"
                            },
                            "alternative_names": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "issuer": {
                              "properties": {
                                "state_or_province": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "country": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "organization": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "distinguished_name": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "locality": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "common_name": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                },
                                "organizational_unit": {
                                  "ignore_above": 1024,
                                  "type": "keyword"
                                }
                              }
                            }
                          }
                        },
                        "size": {
                          "type": "long"
                        },
                        "mime_type": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "pe": {
                          "properties": {
                            "file_version": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "product": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "imphash": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "description": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "company": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "original_file_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "architecture": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "attributes": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "device": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "hash": {
                          "properties": {
                            "sha1": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "sha256": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "sha512": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "ssdeep": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "md5": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        }
                      }
                    },
                    "provider": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "port": {
                      "type": "long"
                    },
                    "modified_at": {
                      "type": "date"
                    },
                    "email": {
                      "properties": {
                        "address": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    }
                  }
                },
                "matched": {
                  "properties": {
                    "field": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "atomic": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "index": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "group": {
              "properties": {
                "reference": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "alias": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "tactic": {
              "properties": {
                "reference": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "user": {
          "properties": {
            "effective": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "full_name": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "roles": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "changes": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "email": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "hash": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "group": {
              "properties": {
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "target": {
              "properties": {
                "full_name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  }
                },
                "domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "roles": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "fields": {
                    "text": {
                      "type": "match_only_text"
                    }
                  },
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "email": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "hash": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "group": {
                  "properties": {
                    "domain": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        },
        "transaction": {
          "properties": {
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "span": {
          "properties": {
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        }
      }
    }
  },
  "index_patterns": [
    "winlogbeat-8.17*"
  ],
  "composed_of": [],
  "ignore_missing_component_templates": [],
  "allow_auto_create": true
}
EOF

# Create enrich-rip index template
curl -X PUT "http://localhost:30920/_index_template/enrich-rip" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "number_of_replicas": "0"
      }
    },
    "mappings": {
      "properties": {
        "ripcodes": {
          "type": "long"
        },
        "rip1": {
          "type": "long"
        }
      }
    }
  },
  "index_patterns": [
    "enrich-rip*"
  ],
  "composed_of": [],
  "ignore_missing_component_templates": [],
  "allow_auto_create": true
}
EOF

# Load enrich-rip index data
curl -X POST "http://localhost:30920/enrich-rip/_bulk" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" --data-binary @/root/simple-data-generator/enrich-rip.ndjson

# Create the enrich-rip enrichment
curl -X PUT "http://localhost:30920/_enrich/policy/remote-ips" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "match": {
    "indices": "enrich-rip",
    "match_field": "ripcodes",
    "enrich_fields": ["rip1"]
  }
}
EOF

# Execute enrich-rip enrichment
curl -X POST "http://localhost:30920/_enrich/policy/remote-ips/_execute" -u "sdg:changeme"

# Add enrich-logs-network_traffic & enrich-logs-network_traffic-dns & logs-network_traffic-cleanup ingest pipeline
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/enrich-logs-network_traffic-dns" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/enrich-logs-network_traffic-dns.json
curl -X PUT "http://localhost:30920/_ingest/pipeline/logs-network_traffic-cleanup" -H "Content-Type: application/x-ndjson" -u "sdg:changeme" -d @/root/simple-data-generator/logs-network_traffic-cleanup.json

# Add logs-network_traffic component templates
curl -X PUT "http://localhost:30920/_component_template/logs-network_traffic.dns@package" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "logs"
        },
        "default_pipeline": "logs-network_traffic.dns-1.32.1",
        "mapping": {
          "total_fields": {
            "limit": "1000"
          }
        }
      }
    },
    "mappings": {
      "dynamic_templates": [
        {
          "container.labels": {
            "path_match": "container.labels.*",
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        },
        {
          "_embedded_ecs-ecs_timestamp": {
            "path_match": "@timestamp",
            "mapping": {
              "ignore_malformed": false,
              "type": "date"
            }
          }
        },
        {
          "_embedded_ecs-data_stream_to_constant": {
            "path_match": "data_stream.*",
            "mapping": {
              "type": "constant_keyword"
            }
          }
        },
        {
          "_embedded_ecs-resolved_ip_to_ip": {
            "mapping": {
              "type": "ip"
            },
            "match": "resolved_ip"
          }
        },
        {
          "_embedded_ecs-forwarded_ip_to_ip": {
            "mapping": {
              "type": "ip"
            },
            "match_mapping_type": "string",
            "match": "forwarded_ip"
          }
        },
        {
          "_embedded_ecs-ip_to_ip": {
            "mapping": {
              "type": "ip"
            },
            "match_mapping_type": "string",
            "match": "ip"
          }
        },
        {
          "_embedded_ecs-x509_public_key_exponent_non_indexed_long": {
            "path_match": "*.x509.public_key_exponent",
            "mapping": {
              "index": false,
              "type": "long",
              "doc_values": false
            }
          }
        },
        {
          "_embedded_ecs-port_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "port"
          }
        },
        {
          "_embedded_ecs-thread_id_to_long": {
            "path_match": "*.thread.id",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-status_code_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "status_code"
          }
        },
        {
          "_embedded_ecs-line_to_long": {
            "path_match": "*.file.line",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-priority_to_long": {
            "path_match": "log.syslog.priority",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-code_to_long": {
            "path_match": "*.facility.code",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-bytes_to_long": {
            "mapping": {
              "type": "long"
            },
            "path_unmatch": "*.data.bytes",
            "match": "bytes"
          }
        },
        {
          "_embedded_ecs-packets_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "packets"
          }
        },
        {
          "_embedded_ecs-public_key_exponent_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "public_key_exponent"
          }
        },
        {
          "_embedded_ecs-severity_to_long": {
            "path_match": "event.severity",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-duration_to_long": {
            "path_match": "event.duration",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-pid_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "pid"
          }
        },
        {
          "_embedded_ecs-uptime_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "uptime"
          }
        },
        {
          "_embedded_ecs-sequence_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "sequence"
          }
        },
        {
          "_embedded_ecs-entropy_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "*entropy"
          }
        },
        {
          "_embedded_ecs-size_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "*size"
          }
        },
        {
          "_embedded_ecs-entrypoint_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "entrypoint"
          }
        },
        {
          "_embedded_ecs-ttl_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "ttl"
          }
        },
        {
          "_embedded_ecs-major_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "major"
          }
        },
        {
          "_embedded_ecs-minor_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "minor"
          }
        },
        {
          "_embedded_ecs-as_number_to_long": {
            "path_match": "*.as.number",
            "mapping": {
              "type": "long"
            }
          }
        },
        {
          "_embedded_ecs-pgid_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "pgid"
          }
        },
        {
          "_embedded_ecs-exit_code_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "exit_code"
          }
        },
        {
          "_embedded_ecs-chi_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "chi2"
          }
        },
        {
          "_embedded_ecs-args_count_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "args_count"
          }
        },
        {
          "_embedded_ecs-virtual_address_to_long": {
            "mapping": {
              "type": "long"
            },
            "match": "virtual_address"
          }
        },
        {
          "_embedded_ecs-io_text_to_wildcard": {
            "path_match": "*.io.text",
            "mapping": {
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-strings_to_wildcard": {
            "path_match": "registry.data.strings",
            "mapping": {
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-path_to_wildcard": {
            "path_match": "*url.path",
            "mapping": {
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-message_id_to_wildcard": {
            "mapping": {
              "type": "wildcard"
            },
            "match": "message_id"
          }
        },
        {
          "_embedded_ecs-command_line_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "match": "command_line"
          }
        },
        {
          "_embedded_ecs-error_stack_trace_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            },
            "match": "stack_trace"
          }
        },
        {
          "_embedded_ecs-http_content_to_multifield": {
            "path_match": "*.body.content",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-url_full_to_multifield": {
            "path_match": "*.url.full",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-url_original_to_multifield": {
            "path_match": "*.url.original",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-user_agent_original_to_multifield": {
            "path_match": "user_agent.original",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "wildcard"
            }
          }
        },
        {
          "_embedded_ecs-error_message_to_match_only": {
            "path_match": "error.message",
            "mapping": {
              "type": "match_only_text"
            }
          }
        },
        {
          "_embedded_ecs-message_match_only_text": {
            "path_match": "message",
            "mapping": {
              "type": "match_only_text"
            }
          }
        },
        {
          "_embedded_ecs-event_original_non_indexed_keyword": {
            "path_match": "event.original",
            "mapping": {
              "index": false,
              "type": "keyword",
              "doc_values": false
            }
          }
        },
        {
          "_embedded_ecs-agent_name_to_keyword": {
            "path_match": "agent.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-service_name_to_keyword": {
            "path_match": "*.service.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-sections_name_to_keyword": {
            "path_match": "*.sections.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-resource_name_to_keyword": {
            "path_match": "*.resource.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-observer_name_to_keyword": {
            "path_match": "observer.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-question_name_to_keyword": {
            "path_match": "*.question.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-group_name_to_keyword": {
            "path_match": "*.group.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-geo_name_to_keyword": {
            "path_match": "*.geo.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-host_name_to_keyword": {
            "path_match": "host.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-severity_name_to_keyword": {
            "path_match": "*.severity.name",
            "mapping": {
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-title_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "match": "title"
          }
        },
        {
          "_embedded_ecs-executable_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "match": "executable"
          }
        },
        {
          "_embedded_ecs-file_path_to_multifield": {
            "path_match": "*.file.path",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-file_target_path_to_multifield": {
            "path_match": "*.file.target_path",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-name_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "match": "name"
          }
        },
        {
          "_embedded_ecs-full_name_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "match": "full_name"
          }
        },
        {
          "_embedded_ecs-os_full_to_multifield": {
            "path_match": "*.os.full",
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            }
          }
        },
        {
          "_embedded_ecs-working_directory_to_multifield": {
            "mapping": {
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              },
              "type": "keyword"
            },
            "match": "working_directory"
          }
        },
        {
          "_embedded_ecs-timestamp_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "timestamp"
          }
        },
        {
          "_embedded_ecs-delivery_timestamp_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "delivery_timestamp"
          }
        },
        {
          "_embedded_ecs-not_after_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "not_after"
          }
        },
        {
          "_embedded_ecs-not_before_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "not_before"
          }
        },
        {
          "_embedded_ecs-accessed_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "accessed"
          }
        },
        {
          "_embedded_ecs-origination_timestamp_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "origination_timestamp"
          }
        },
        {
          "_embedded_ecs-created_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "created"
          }
        },
        {
          "_embedded_ecs-installed_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "installed"
          }
        },
        {
          "_embedded_ecs-creation_date_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "creation_date"
          }
        },
        {
          "_embedded_ecs-ctime_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "ctime"
          }
        },
        {
          "_embedded_ecs-mtime_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "mtime"
          }
        },
        {
          "_embedded_ecs-ingested_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "ingested"
          }
        },
        {
          "_embedded_ecs-start_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "start"
          }
        },
        {
          "_embedded_ecs-end_to_date": {
            "mapping": {
              "type": "date"
            },
            "match": "end"
          }
        },
        {
          "_embedded_ecs-score_base_to_float": {
            "path_match": "*.score.base",
            "mapping": {
              "type": "float"
            }
          }
        },
        {
          "_embedded_ecs-score_temporal_to_float": {
            "path_match": "*.score.temporal",
            "mapping": {
              "type": "float"
            }
          }
        },
        {
          "_embedded_ecs-score_to_float": {
            "mapping": {
              "type": "float"
            },
            "match": "*_score"
          }
        },
        {
          "_embedded_ecs-score_norm_to_float": {
            "mapping": {
              "type": "float"
            },
            "match": "*_score_norm"
          }
        },
        {
          "_embedded_ecs-usage_to_float": {
            "mapping": {
              "scaling_factor": 1000,
              "type": "scaled_float"
            },
            "match": "usage"
          }
        },
        {
          "_embedded_ecs-location_to_geo_point": {
            "mapping": {
              "type": "geo_point"
            },
            "match": "location"
          }
        },
        {
          "_embedded_ecs-same_as_process_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "same_as_process"
          }
        },
        {
          "_embedded_ecs-established_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "established"
          }
        },
        {
          "_embedded_ecs-resumed_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "resumed"
          }
        },
        {
          "_embedded_ecs-max_bytes_per_process_exceeded_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "max_bytes_per_process_exceeded"
          }
        },
        {
          "_embedded_ecs-interactive_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "interactive"
          }
        },
        {
          "_embedded_ecs-exists_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "exists"
          }
        },
        {
          "_embedded_ecs-trusted_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "trusted"
          }
        },
        {
          "_embedded_ecs-valid_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "valid"
          }
        },
        {
          "_embedded_ecs-go_stripped_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "go_stripped"
          }
        },
        {
          "_embedded_ecs-coldstart_to_boolean": {
            "mapping": {
              "type": "boolean"
            },
            "match": "coldstart"
          }
        },
        {
          "_embedded_ecs-exports_to_flattened": {
            "mapping": {
              "type": "flattened"
            },
            "match": "exports"
          }
        },
        {
          "_embedded_ecs-structured_data_to_flattened": {
            "mapping": {
              "type": "flattened"
            },
            "match": "structured_data"
          }
        },
        {
          "_embedded_ecs-imports_to_flattened": {
            "mapping": {
              "type": "flattened"
            },
            "match": "*imports"
          }
        },
        {
          "_embedded_ecs-attachments_to_nested": {
            "mapping": {
              "type": "nested"
            },
            "match": "attachments"
          }
        },
        {
          "_embedded_ecs-segments_to_nested": {
            "mapping": {
              "type": "nested"
            },
            "match": "segments"
          }
        },
        {
          "_embedded_ecs-elf_sections_to_nested": {
            "path_match": "*.elf.sections",
            "mapping": {
              "type": "nested"
            }
          }
        },
        {
          "_embedded_ecs-pe_sections_to_nested": {
            "path_match": "*.pe.sections",
            "mapping": {
              "type": "nested"
            }
          }
        },
        {
          "_embedded_ecs-macho_sections_to_nested": {
            "path_match": "*.macho.sections",
            "mapping": {
              "type": "nested"
            }
          }
        }
      ],
      "properties": {
        "container": {
          "dynamic": true,
          "type": "object",
          "properties": {
            "image": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "labels": {
              "dynamic": true,
              "type": "object"
            }
          }
        },
        "request": {
          "type": "text"
        },
        "server": {
          "properties": {
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "process": {
              "properties": {
                "args": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "start": {
                  "type": "date"
                },
                "working_directory": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "executable": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "destination": {
          "properties": {
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "network_traffic": {
          "properties": {
            "dns": {
              "properties": {
                "additionals": {
                  "type": "flattened"
                },
                "opt": {
                  "properties": {
                    "ext_rcode": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "udp_size": {
                      "type": "long"
                    },
                    "do": {
                      "type": "boolean"
                    },
                    "version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "method": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "question": {
                  "properties": {
                    "etld_plus_one": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "resource": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "answers_count": {
                  "type": "long"
                },
                "query": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "authorities_count": {
                  "type": "long"
                },
                "flags": {
                  "properties": {
                    "authoritative": {
                      "type": "boolean"
                    },
                    "truncated_response": {
                      "type": "boolean"
                    },
                    "recursion_available": {
                      "type": "boolean"
                    },
                    "recursion_desired": {
                      "type": "boolean"
                    },
                    "checking_disabled": {
                      "type": "boolean"
                    },
                    "authentic_data": {
                      "type": "boolean"
                    }
                  }
                },
                "additionals_count": {
                  "type": "long"
                },
                "authorities": {
                  "type": "flattened"
                }
              }
            },
            "status": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "source": {
          "properties": {
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "type": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "network": {
          "properties": {
            "community_id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "forwarded_ip": {
              "type": "ip"
            },
            "protocol": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "bytes": {
              "type": "long"
            },
            "transport": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "direction": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "cloud": {
          "properties": {
            "availability_zone": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "image": {
              "properties": {
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "instance": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "provider": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "machine": {
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "project": {
              "properties": {
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "region": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "account": {
              "properties": {
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            }
          }
        },
        "path": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "observer": {
          "properties": {
            "hostname": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "ecs": {
          "properties": {
            "version": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "related": {
          "properties": {
            "hosts": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "host": {
          "properties": {
            "hostname": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "os": {
              "properties": {
                "build": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "kernel": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "codename": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword",
                  "fields": {
                    "text": {
                      "type": "text"
                    }
                  }
                },
                "family": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "platform": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "domain": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "ip": {
              "type": "ip"
            },
            "containerized": {
              "type": "boolean"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "mac": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "architecture": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "client": {
          "properties": {
            "geo": {
              "properties": {
                "continent_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "region_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "city_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_iso_code": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "country_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "location": {
                  "type": "geo_point"
                },
                "region_name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "process": {
              "properties": {
                "args": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "start": {
                  "type": "date"
                },
                "working_directory": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "executable": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "port": {
              "type": "long"
            },
            "bytes": {
              "type": "long"
            },
            "ip": {
              "type": "ip"
            }
          }
        },
        "event": {
          "properties": {
            "duration": {
              "type": "long"
            },
            "kind": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "module": {
              "type": "constant_keyword",
              "value": "network_traffic"
            },
            "start": {
              "type": "date"
            },
            "end": {
              "type": "date"
            },
            "category": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "dataset": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "flow": {
          "properties": {
            "vlan": {
              "type": "long"
            },
            "final": {
              "type": "boolean"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "process": {
          "properties": {
            "args": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "name": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "start": {
              "type": "date"
            },
            "working_directory": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            },
            "executable": {
              "ignore_above": 1024,
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "match_only_text"
                }
              }
            }
          }
        },
        "method": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "resource": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "query": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "dns": {
          "properties": {
            "resolved_ip": {
              "type": "ip"
            },
            "response_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "question": {
              "properties": {
                "registered_domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "top_level_domain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "etld_plus_one": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "subdomain": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "class": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "answers": {
              "properties": {
                "data": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "class": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ttl": {
                  "type": "long"
                }
              }
            },
            "flags": {
              "properties": {
                "authoritative": {
                  "type": "boolean"
                },
                "truncated_response": {
                  "type": "boolean"
                },
                "recursion_available": {
                  "type": "boolean"
                },
                "recursion_desired": {
                  "type": "boolean"
                },
                "checking_disabled": {
                  "type": "boolean"
                },
                "authentic_data": {
                  "type": "boolean"
                }
              }
            },
            "additionals_count": {
              "type": "long"
            },
            "header_flags": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "type": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "authorities": {
              "type": "flattened"
            },
            "op_code": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "additionals": {
              "type": "flattened"
            },
            "opt": {
              "properties": {
                "ext_rcode": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "udp_size": {
                  "type": "long"
                },
                "do": {
                  "type": "boolean"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "answers_count": {
              "type": "long"
            },
            "authorities_count": {
              "type": "long"
            },
            "id": {
              "ignore_above": 1024,
              "type": "keyword"
            }
          }
        },
        "params": {
          "type": "text"
        },
        "tags": {
          "ignore_above": 1024,
          "type": "keyword"
        },
        "@timestamp": {
          "ignore_malformed": false,
          "type": "date"
        },
        "data_stream": {
          "properties": {
            "namespace": {
              "type": "constant_keyword"
            },
            "type": {
              "type": "constant_keyword"
            },
            "dataset": {
              "type": "constant_keyword"
            }
          }
        },
        "response": {
          "type": "text"
        },
        "status": {
          "ignore_above": 1024,
          "type": "keyword"
        }
      }
    }
  },
  "_meta": {
    "package": {
      "name": "network_traffic"
    },
    "managed_by": "fleet",
    "managed": true
  }
}
EOF

# Create the logs-network_traffic.dns index template
curl -X PUT "http://localhost:30920/_index_template/logs-network_traffic.dns" -H "Content-Type: application/json" -u "sdg:changeme" -d @- << 'EOF'
{
  "priority": 200,
  "template": {
    "settings": {
      "index": {
          "default_pipeline": "enrich-logs-network_traffic",
          "number_of_shards": "1",
          "number_of_replicas": "0"
      }
    },
    "mappings": {
      "_meta": {
        "package": {
          "name": "network_traffic"
        },
        "managed_by": "fleet",
        "managed": true
      }
    }
  },
  "index_patterns": [
    "logs-network_traffic.dns*"
  ],
  "composed_of": [
    "logs@mappings",
    "logs@settings",
    "logs-network_traffic.dns@package",
    "ecs@mappings",
    ".fleet_globals-1",
    ".fleet_agent_id_verification-1",
    "logs@custom"
  ],
  "ignore_missing_component_templates": [
    "logs@custom",
    "logs-network_traffic.dns@custom"
  ],
  "allow_auto_create": true,
  "_meta": {
    "package": {
      "name": "network_traffic"
    },
    "managed_by": "fleet",
    "managed": true
  }
}
EOF

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
cd simple-data-generator && gradle clean; gradle build fatJar
echo "Starting data ingestion, press CTRL + C to unplug from the Matrix."
java -jar /root/simple-data-generator/build/libs/simple-data-generator-1.0.0-SNAPSHOT.jar /root/simple-data-generator/secops.yml
