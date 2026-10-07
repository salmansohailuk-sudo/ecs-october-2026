#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
docker build -t ecomm-ecs-frontend:latest "$ROOT/frontend"
docker build -t ecomm-ecs-backend:latest "$ROOT/backend"
docker build -t monitoring-ecs-prometheus:latest "$ROOT/monitoring/prometheus"
docker build -t monitoring-ecs-grafana:latest "$ROOT/monitoring/grafana"
echo "All ECS images built."
