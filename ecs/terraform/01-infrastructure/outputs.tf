output "builder_public_ip" {
  value = aws_instance.builder.public_ip
}

output "builder_instance_id" {
  value = aws_instance.builder.id
}

output "db_endpoint" {
  value = aws_db_instance.mysql.address
}

output "ecr_frontend" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_prometheus" {
  value = aws_ecr_repository.prometheus.repository_url
}

output "ecr_grafana" {
  value = aws_ecr_repository.grafana.repository_url
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

# Application Load Balancer outputs — added for Stage 1

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "frontend_target_group_arn" {
  description = "Frontend target group ARN for Stage 2 ECS"
  value       = aws_lb_target_group.frontend.arn
}

output "grafana_target_group_arn" {
  description = "Grafana target group ARN for Stage 2 ECS"
  value       = aws_lb_target_group.grafana.arn
}

output "prometheus_target_group_arn" {
  description = "Prometheus target group ARN for Stage 2 ECS"
  value       = aws_lb_target_group.prometheus.arn
}
