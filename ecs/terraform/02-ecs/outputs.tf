output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "frontend_url" {
  value = "http://${var.alb_dns_name}"
}

output "grafana_url" {
  value = "http://${var.alb_dns_name}:3000"
}

output "prometheus_url" {
  value = "http://${var.alb_dns_name}:9090"
}
