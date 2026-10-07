resource "aws_ecr_repository" "frontend" { name="ecomm-ecs-frontend" }
resource "aws_ecr_repository" "backend" { name="ecomm-ecs-backend" }
resource "aws_ecr_repository" "prometheus" { name="monitoring-ecs-prometheus" }
resource "aws_ecr_repository" "grafana" { name="monitoring-ecs-grafana" }
