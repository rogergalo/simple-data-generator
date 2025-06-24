#!/bin/bash

# Function to get and confirm the enrollment token
get_token() {
    while true; do
        read -rp "Please paste your Elastic Agent enrollment token: " ENROLLMENT_TOKEN
        echo "You entered: $ENROLLMENT_TOKEN"
        read -rp "Is this correct? (yes/no): " CONFIRM
        case "$CONFIRM" in
            [Yy][Ee][Ss]|[Yy]) break ;;
            *) echo "Let's try again."; continue ;;
        esac
    done
}

# Get the enrollment token from user
get_token

# Create the docker network 'elastic' if it doesn't exist
if ! docker network ls | grep -q ' elastic '; then
    echo "Creating Docker network 'elastic'..."
    docker network create elastic
else
    echo "Docker network 'elastic' already exists."
fi

# Run the Elastic Agent Synthetics container
echo "Starting Elastic-Agent-Synthetics container..."
sudo docker run  -d \
    --restart=always \
    --name Elastic-Agent-Synthetics \
    --network elastic \
    --env FLEET_ENROLL=1 \
    --env FLEET_URL=https://fleet-server-agent-http.default.svc:8220 \
    --env FLEET_ENROLLMENT_TOKEN="$ENROLLMENT_TOKEN" \
    docker.elastic.co/elastic-agent/elastic-agent-complete:8.18.1

cat <<EOF

====================================================================
Elastic Agent (Synthetics) Docker Container Installation Complete!
====================================================================

You have just installed the Elastic Agent using the 'elastic-agent-complete:8.18.1' Docker image.
This containerized agent allows you to run **synthetic browser monitors** directly on your host.

Details of what was done:
- The **enrollment token** you provided was used to securely register your agent with Fleet.
- The Docker network **'elastic'** was created (if it did not already exist) to allow the agent to communicate with other Elastic stack containers.
- The container was given the name **Elastic-Agent-Synthetics** for easy identification.
- The **--restart=always** option ensures your agent container will **restart automatically** if your machine reboots or if the container crashes, keeping your monitoring consistent.
- The Elastic Agent connects to **https://fleet-server-agent-http.default.svc:8220**, so make sure your Fleet Server is running and accessible at that address.

You can check the agent’s status with:
  docker logs -f Elastic-Agent-Synthetics

To remove the agent:
  docker rm -f Elastic-Agent-Synthetics

====================================================================

EOF

# Wait for user confirmation before exiting, but leave the info on screen
read -rp "Press ENTER to finish and leave this information visible on your screen..."

