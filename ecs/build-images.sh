#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "========================================"
echo "Building ECS Docker images"
echo "========================================"

docker build -t ecomm-ecs-frontend ./frontend
docker build -t ecomm-ecs-backend ./backend
docker build -t monitoring-ecs-prometheus ./monitoring/prometheus
docker build -t monitoring-ecs-grafana ./monitoring/grafana

echo
echo "Images built successfully:"
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' \
  | grep -E 'ecomm-ecs-|monitoring-ecs-' || true

echo
echo "Build complete."
