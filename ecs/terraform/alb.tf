resource "aws_lb" "ecs" {
  name="ecomm-ecs-alb" internal=false load_balancer_type="application"
  security_groups=[aws_security_group.alb.id]
  subnets=[aws_subnet.public_a.id,aws_subnet.public_b.id]
}
resource "aws_lb_target_group" "frontend" {
  name="ecomm-ecs-frontend" port=80 protocol="HTTP" target_type="ip" vpc_id=aws_vpc.ecs.id
  health_check { path="/health" port="80" }
}
resource "aws_lb_target_group" "prometheus" {
  name="ecomm-ecs-prometheus" port=9090 protocol="HTTP" target_type="ip" vpc_id=aws_vpc.ecs.id
  health_check { path="/-/healthy" port="9090" }
}
resource "aws_lb_target_group" "grafana" {
  name="ecomm-ecs-grafana" port=3000 protocol="HTTP" target_type="ip" vpc_id=aws_vpc.ecs.id
  health_check { path="/api/health" port="3000" }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn=aws_lb.ecs.arn port=80 protocol="HTTP"
  default_action { type="forward" target_group_arn=aws_lb_target_group.frontend.arn }
}
resource "aws_lb_listener_rule" "prometheus" {
  listener_arn=aws_lb_listener.http.arn priority=10
  action { type="forward" target_group_arn=aws_lb_target_group.prometheus.arn }
  condition { path_pattern { values=["/prometheus","/prometheus/*"] } }
}
resource "aws_lb_listener_rule" "grafana" {
  listener_arn=aws_lb_listener.http.arn priority=20
  action { type="forward" target_group_arn=aws_lb_target_group.grafana.arn }
  condition { path_pattern { values=["/grafana","/grafana/*"] } }
}
