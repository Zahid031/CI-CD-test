#!/bin/bash
set -e

PR_ID=$1
BRANCH_NAME=$2
PORT_RANGE_START=8000
PORT_RANGE_END=8100

PORT_FILE="/home/ubuntu/used_ports.txt"
ENV_FILE=".env"
PROJECT_NAME="pr_${PR_ID}"


if [ ! -f "$PORT_FILE" ]; then touch "$PORT_FILE"; fi

# Check if this PR already has a port assigned.
EXISTING_PORT=$(grep "^${PROJECT_NAME}:" "$PORT_FILE" | cut -d: -f2)

if [ -n "$EXISTING_PORT" ]; then
    APP_PORT=$EXISTING_PORT
else
    for PORT in $(seq $PORT_RANGE_START $PORT_RANGE_END); do
        if ! grep -q ":$PORT" "$PORT_FILE"; then
            echo "$PROJECT_NAME:$PORT" >> "$PORT_FILE"
            APP_PORT=$PORT
            break
        fi
    done
fi

if [ -z "$APP_PORT" ]; then
    echo " No available ports in $PORT_RANGE_START–$PORT_RANGE_END"
    exit 1
fi

# Create .env file
cat > "$ENV_FILE" <<EOF
APP_PORT=${APP_PORT}
DB_PORT=5${PR_ID}
POSTGRES_DB=blog_db_${PR_ID}
POSTGRES_USER=blog_user_${PR_ID}
POSTGRES_PASSWORD=blog_user_${PR_ID}
EOF

# Build and deploy
docker compose -p "$PROJECT_NAME" --env-file "$ENV_FILE" up -d --build
echo "ok"
echo "okkkk"
