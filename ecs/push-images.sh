#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Logging into ECR: ${REGISTRY}"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"

push_image() {
  local local_image="$1"
  local repository="$2"
  echo "Pushing ${repository}:latest"
  docker tag "${local_image}:latest" "${REGISTRY}/${repository}:latest"
  docker push "${REGISTRY}/${repository}:latest"
}

push_image "ecomm-ecs-frontend" "ecomm-ecs-frontend"
push_image "ecomm-ecs-backend" "ecomm-ecs-backend"
push_image "monitoring-ecs-prometheus" "monitoring-ecs-prometheus"
push_image "monitoring-ecs-grafana" "monitoring-ecs-grafana"

echo "All ECS images pushed successfully."
