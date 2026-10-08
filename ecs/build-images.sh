#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "========================================"
echo "Building ECS Docker images with Docker Compose"
echo "========================================"

docker compose build

echo
echo "Images built successfully:"
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' \\
  | grep -E 'ecomm-ecs-|monitoring-ecs-' || true

echo
echo "Build complete. No containers were started."
