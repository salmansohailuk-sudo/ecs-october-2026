output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

# CHANGED: ALB is created in Stage 1, so use the variable passed from Stage 1.

output "alb_dns_name" {
  value = var.alb_dns_name
}

# CHANGED: Use the Stage 1 ALB DNS variable.

output "frontend_url" {
  value = "http://${var.alb_dns_name}"
}

# CHANGED: Assumes Grafana is directly reachable on port 3000.

output "grafana_url" {
  value = "http://${var.alb_dns_name}:3000"
}

# CHANGED: Assumes Prometheus is directly reachable on port 9090.

output "prometheus_url" {
  value = "http://${var.alb_dns_name}:9090"
}

output "cloud_map_namespace" {
  value = aws_service_discovery_private_dns_namespace.main.name
}
