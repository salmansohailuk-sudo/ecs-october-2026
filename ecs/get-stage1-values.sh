#!/bin/bash
# Prints the Stage 1 values needed by Stage 2.
# Run it where you ran Stage 1 "terraform apply" (it reads the Terraform outputs).
# It only prints. Copy the lines into terraform/02-ecs/terraform.tfvars by hand.

cd "$(dirname "$0")/terraform/01-infrastructure" || exit 1

echo "# Copy these lines into terraform/02-ecs/terraform.tfvars"
echo
echo "vpc_id                = \"$(terraform output -raw vpc_id)\""
echo "public_subnet_a_id    = \"$(terraform output -raw public_subnet_a_id)\""
echo "public_subnet_b_id    = \"$(terraform output -raw public_subnet_b_id)\""
echo "ecs_security_group_id = \"$(terraform output -raw ecs_security_group_id)\""
echo "tg_frontend_arn       = \"$(terraform output -raw tg_frontend_arn)\""
echo "tg_grafana_arn        = \"$(terraform output -raw tg_grafana_arn)\""
echo "tg_prometheus_arn     = \"$(terraform output -raw tg_prometheus_arn)\""
echo "alb_dns_name          = \"$(terraform output -raw alb_dns_name)\""
echo "ecr_frontend          = \"$(terraform output -raw ecr_frontend)\""
echo "ecr_backend           = \"$(terraform output -raw ecr_backend)\""
echo "ecr_prometheus        = \"$(terraform output -raw ecr_prometheus)\""
echo "ecr_grafana           = \"$(terraform output -raw ecr_grafana)\""
echo "db_endpoint           = \"$(terraform output -raw db_endpoint)\""
