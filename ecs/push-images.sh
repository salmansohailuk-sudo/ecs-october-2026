#!/bin/bash
set -euo pipefail
AWS_REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"
for x in ecomm-ecs-frontend ecomm-ecs-backend monitoring-ecs-prometheus monitoring-ecs-grafana; do
  docker tag "$x:latest" "$REGISTRY/$x:latest"
  docker push "$REGISTRY/$x:latest"
done
