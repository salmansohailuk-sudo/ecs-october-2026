#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE1_DIR="$SCRIPT_DIR/terraform/01-infrastructure"

outputs=(
  vpc_id
  public_subnet_a_id
  public_subnet_b_id
  ecr_frontend
  ecr_backend
  ecr_prometheus
  ecr_grafana
  db_endpoint
  alb_dns_name
  alb_security_group_id
  frontend_target_group_arn
  grafana_target_group_arn
  prometheus_target_group_arn
)

echo "# Stage 1 outputs — copy into terraform/02-ecs/terraform.tfvars"
echo

for name in "${outputs[@]}"; do
  value="$(terraform -chdir="$STAGE1_DIR" output -raw "$name")"
  printf '%-30s = "%s"\n' "$name" "$value"
done
