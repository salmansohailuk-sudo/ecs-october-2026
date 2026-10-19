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

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "frontend_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "grafana_url" {
  value = "http://${aws_lb.main.dns_name}:3000"
}

output "prometheus_url" {
  value = "http://${aws_lb.main.dns_name}:9090"
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "tg_frontend_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "tg_grafana_arn" {
  value = aws_lb_target_group.grafana.arn
}

output "tg_prometheus_arn" {
  value = aws_lb_target_group.prometheus.arn
}
