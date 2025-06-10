#!/bin/bash

set -e

# Initialize variables
NO_CACHE=""

echo "=== Starting Rollcall build process ==="

# Parse command line arguments
for arg in "$@"; do
  if [ "$arg" = "--no-cache" ]; then
    NO_CACHE="--no-cache"
    echo "No cache option enabled. Docker images will be built without cache."
  fi
done

# Copy necessary configuration files
echo "Copying docker-compose configuration..."
cp inst-cli/docker-compose/docker-compose.local.yml docker-compose.local.yml

# Ensure .env file has the correct COMPOSE_FILE setting
echo "Configuring .env file..."
ENV_CONTENT="# Override the default docker environment with inst-cli + traefik specific
# settings. This file is used by the docker-compose command to
# run rollcall locally. It is not used in production.
COMPOSE_FILE=docker-compose.local.yml"

# Check if .env file exists
if [ ! -f .env ]; then
  cp env.sample .env
  echo "Copied env.sample to .env, make sure to update it with your settings"
fi

# Check if the file already has the COMPOSE_FILE setting
if grep -q "COMPOSE_FILE=docker-compose.local.yml" .env; then
  echo ".env file already has the correct COMPOSE_FILE setting"
else
  # Prepend the content to the existing .env file
  echo "Adding Docker Compose configuration to .env file"
  TEMP_FILE=$(mktemp)
  echo "$ENV_CONTENT" > "$TEMP_FILE"
  cat .env >> "$TEMP_FILE"
  mv "$TEMP_FILE" .env
fi

echo "Copying session store configuration..."
cp inst-cli/config/initializers/session_store.rb config/initializers/session_store.rb

# Build the containers
echo "Building Docker containers..."
docker compose build $NO_CACHE

echo "=== Build process completed successfully ==="
