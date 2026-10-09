#!/usr/bin/env bash

#

# Print Stage 1 Terraform outputs needed by Stage 2.

# This script only prints values; it does NOT modify terraform.tfvars.

#

# Run from the repository's ecs/ directory:

# ./get-stage1-values.sh

#

# Or pass the path to the ecs/ directory:

# ./get-stage1-values.sh /path/to/ecs

#

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$SCRIPT_DIR}"
STAGE1_DIR="${PROJECT_DIR}/terraform/01-infrastructure"

if ! command -v terraform >/dev/null 2>&1; then
echo "ERROR: Terraform is not installed or not on PATH." >&2
exit 1
fi

if [[ ! -d "$STAGE1_DIR" ]]; then
echo "ERROR: Stage 1 directory not found: $STAGE1_DIR" >&2
echo "Run this script from the ecs/ directory, or pass the ecs/ path as an argument." >&2
exit 1
fi

cd "$STAGE1_DIR"

echo "# Copy these lines into terraform/02-ecs/terraform.tfvars"
echo "# This script only reads Terraform outputs; it does not edit any files."
echo

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

for name in "${outputs[@]}"; do
if value="$(terraform output -raw "$name" 2>/dev/null)"; then
printf '%-30s = "%s"\n' "$name" "$value"
else
printf 'ERROR: Could not read Terraform output "%s".\n' "$name" >&2
echo "Check the output names with: terraform output" >&2
echo "Ensure Stage 1 has been applied and the output exists in outputs.tf." >&2
exit 1
fi
done
