#!/bin/bash

set -e

echo "=== Starting Rollcall setup process ==="

# Start the containers in detached mode
echo "Starting Docker containers..."
docker compose up -d

# Wait for services to be fully up before proceeding
echo "Waiting for services to initialize..."
sleep 5

# Create the database
echo "Creating database..."
docker compose exec web bundle exec rake db:create
sleep 2

# Run migrations
echo "Running database migrations..."
docker compose exec web bundle exec rake db:migrate

echo "=== Setup process completed successfully ==="
echo "Rollcall should now be running at http://rollcall.inseng.test"
