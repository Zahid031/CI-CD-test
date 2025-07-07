#!/bin/bash

set -e

PR_ID=$1
BASE_DIR="/home/ubuntu/pr_deployments"
DEPLOY_DIR="$BASE_DIR/pr_$PR_ID"
PORT_FILE="$BASE_DIR/used_ports.txt"
PROJECT_NAME="pr_${PR_ID}"
ENV_FILE="$DEPLOY_DIR/.env"


if [ -f "$ENV_FILE" ]; then
    docker compose -p "$PROJECT_NAME" --file "$DEPLOY_DIR/docker-compose.yml" --env-file "$ENV_FILE" down -v --remove-orphans --rmi local

fi

rm -rf "$DEPLOY_DIR"
sed -i "/^${PROJECT_NAME}:/d" "$PORT_FILE"

