resource "aws_ecs_cluster" "ecs" {
  name="${var.project_name}-cluster"
  setting { name="containerInsights" value="enhanced" }
}
