data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "frontend" {
  family="${var.project_name}-frontend" requires_compatibilities=["FARGATE"] network_mode="awsvpc"
  cpu="256" memory="512" execution_role_arn=aws_iam_role.execution.arn
  container_definitions=jsonencode([{
    name="frontend" image="${aws_ecr_repository.frontend.repository_url}:latest" essential=true
    portMappings=[{containerPort=80,protocol="tcp"},{containerPort=9113,protocol="tcp"}]
    environment=[{name="BACKEND_URL",value="http://backend.testcluster.local:5000"}]
  }])
}
resource "aws_ecs_service" "frontend" {
  name="frontend" cluster=aws_ecs_cluster.ecs.id task_definition=aws_ecs_task_definition.frontend.arn
  desired_count=1 launch_type="FARGATE"
  network_configuration { subnets=[aws_subnet.public_a.id,aws_subnet.public_b.id] security_groups=[aws_security_group.ecs.id] assign_public_ip=true }
  service_registries { registry_arn=aws_service_discovery_service.frontend.arn }
  load_balancer { target_group_arn=aws_lb_target_group.frontend.arn container_name="frontend" container_port=80 }
  depends_on=[aws_lb_listener.http]
}

resource "aws_ecs_task_definition" "backend" {
  family="${var.project_name}-backend" requires_compatibilities=["FARGATE"] network_mode="awsvpc"
  cpu="256" memory="512" execution_role_arn=aws_iam_role.execution.arn
  container_definitions=jsonencode([{
    name="backend" image="${aws_ecr_repository.backend.repository_url}:latest" essential=true
    portMappings=[{containerPort=5000,protocol="tcp"}]
    environment=[
      {name="DB_HOST",value=aws_db_instance.mysql.address},
      {name="DB_PORT",value="3306"},
      {name="DB_NAME",value="ecomm"},
      {name="DB_USER",value=var.db_username},
      {name="DB_PASSWORD",value=var.db_password}
    ]
  }])
}
resource "aws_ecs_service" "backend" {
  name="backend" cluster=aws_ecs_cluster.ecs.id task_definition=aws_ecs_task_definition.backend.arn
  desired_count=1 launch_type="FARGATE"
  network_configuration { subnets=[aws_subnet.public_a.id,aws_subnet.public_b.id] security_groups=[aws_security_group.ecs.id] assign_public_ip=true }
  service_registries { registry_arn=aws_service_discovery_service.backend.arn }
}

resource "aws_ecs_task_definition" "prometheus" {
  family="${var.project_name}-prometheus" requires_compatibilities=["FARGATE"] network_mode="awsvpc"
  cpu="512" memory="1024" execution_role_arn=aws_iam_role.execution.arn task_role_arn=aws_iam_role.prometheus.arn
  container_definitions=jsonencode([{
    name="prometheus" image="${aws_ecr_repository.prometheus.repository_url}:latest" essential=true
    portMappings=[{containerPort=9090,protocol="tcp"},{containerPort=9106,protocol="tcp"}]
  }])
}
resource "aws_ecs_service" "prometheus" {
  name="prometheus" cluster=aws_ecs_cluster.ecs.id task_definition=aws_ecs_task_definition.prometheus.arn
  desired_count=1 launch_type="FARGATE"
  network_configuration { subnets=[aws_subnet.public_a.id,aws_subnet.public_b.id] security_groups=[aws_security_group.ecs.id] assign_public_ip=true }
  service_registries { registry_arn=aws_service_discovery_service.prometheus.arn }
  load_balancer { target_group_arn=aws_lb_target_group.prometheus.arn container_name="prometheus" container_port=9090 }
}

resource "aws_ecs_task_definition" "grafana" {
  family="${var.project_name}-grafana" requires_compatibilities=["FARGATE"] network_mode="awsvpc"
  cpu="256" memory="512" execution_role_arn=aws_iam_role.execution.arn
  container_definitions=jsonencode([{
    name="grafana" image="${aws_ecr_repository.grafana.repository_url}:latest" essential=true
    portMappings=[{containerPort=3000,protocol="tcp"}]
    environment=[
      {name="GF_SECURITY_ADMIN_USER",value="admin"},
      {name="GF_SECURITY_ADMIN_PASSWORD",value="admin"},
      {name="GF_SERVER_ROOT_URL",value="http://localhost/grafana/"},
      {name="GF_SERVER_SERVE_FROM_SUB_PATH",value="true"}
    ]
  }])
}
resource "aws_ecs_service" "grafana" {
  name="grafana" cluster=aws_ecs_cluster.ecs.id task_definition=aws_ecs_task_definition.grafana.arn
  desired_count=1 launch_type="FARGATE"
  network_configuration { subnets=[aws_subnet.public_a.id,aws_subnet.public_b.id] security_groups=[aws_security_group.ecs.id] assign_public_ip=true }
  service_registries { registry_arn=aws_service_discovery_service.grafana.arn }
  load_balancer { target_group_arn=aws_lb_target_group.grafana.arn container_name="grafana" container_port=3000 }
}
