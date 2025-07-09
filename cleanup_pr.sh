#!/bin/bash

set -e

PR_ID=$1
PORT_FILE="/home/ubuntu/used_ports.txt"
PROJECT_NAME="pr_${PR_ID}"
ENV_FILE=".env"

# This script is executed in the deployment directory on the runner.
# It cleans up the Docker resources for a closed PR.

if [ -f "$ENV_FILE" ]; then
    docker compose -p "$PROJECT_NAME" --file "docker-compose.yml" --env-file "$ENV_FILE" down -v --remove-orphans --rmi local
fi

# This script cleans up the Docker resources. The CD workflow handles directory removal.
# We just need to remove the port from the used_ports.txt file.
if [ -f "$PORT_FILE" ]; then
    sed -i "/^${PROJECT_NAME}:/d" "$PORT_FILE"
fi

