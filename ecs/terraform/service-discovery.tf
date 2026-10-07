resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name=var.namespace_name
  vpc=aws_vpc.ecs.id
  description="Independent ECS service discovery namespace"
}
resource "aws_service_discovery_service" "frontend" {
  name="frontend"
  dns_config { namespace_id=aws_service_discovery_private_dns_namespace.ecs.id dns_records { ttl=10 type="A" } routing_policy="MULTIVALUE" }
}
resource "aws_service_discovery_service" "backend" {
  name="backend"
  dns_config { namespace_id=aws_service_discovery_private_dns_namespace.ecs.id dns_records { ttl=10 type="A" } routing_policy="MULTIVALUE" }
}
resource "aws_service_discovery_service" "prometheus" {
  name="prometheus"
  dns_config { namespace_id=aws_service_discovery_private_dns_namespace.ecs.id dns_records { ttl=10 type="A" } routing_policy="MULTIVALUE" }
}
resource "aws_service_discovery_service" "grafana" {
  name="grafana"
  dns_config { namespace_id=aws_service_discovery_private_dns_namespace.ecs.id dns_records { ttl=10 type="A" } routing_policy="MULTIVALUE" }
}
