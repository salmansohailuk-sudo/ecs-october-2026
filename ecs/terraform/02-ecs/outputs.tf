output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
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

output "cloud_map_namespace" {
  value = aws_service_discovery_private_dns_namespace.main.name
}
