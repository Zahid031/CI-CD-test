#!/bin/bash
set -e

PR_ID=$1
BRANCH_NAME=$2
REPO_URL=$3
PORT_RANGE_START=8000
PORT_RANGE_END=8100

BASE_DIR="/home/ubuntu/pr_deployments"
DEPLOY_DIR="$BASE_DIR/pr_$PR_ID"
PORT_FILE="$BASE_DIR/used_ports.txt"
ENV_FILE="$DEPLOY_DIR/.env"
PROJECT_NAME="pr_${PR_ID}"

mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

# Pick random unused port
if [ ! -f "$PORT_FILE" ]; then touch "$PORT_FILE"; fi
for PORT in $(seq $PORT_RANGE_START $PORT_RANGE_END); do
    if ! grep -q ":$PORT" "$PORT_FILE"; then
        echo "$PROJECT_NAME:$PORT" >> "$PORT_FILE"
        APP_PORT=$PORT
        break
    fi
done

if [ -z "$APP_PORT" ]; then
    echo "❌ No available ports in $PORT_RANGE_START–$PORT_RANGE_END"
    exit 1
fi

# Clone or reset project code
if [ ! -d ".git" ]; then
    git clone "$REPO_URL" .
fi

git fetch origin
git checkout dev
git reset --hard origin/dev
git merge origin/"$BRANCH_NAME" --no-edit

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
