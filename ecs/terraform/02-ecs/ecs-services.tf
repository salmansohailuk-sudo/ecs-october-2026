locals {
  frontend_image   = "${var.ecr_frontend}:latest"
  backend_image    = "${var.ecr_backend}:latest"
  prometheus_image = "${var.ecr_prometheus}:latest"
  grafana_image    = "${var.ecr_grafana}:latest"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = local.frontend_image
    essential = true

    portMappings = [
      { containerPort = 80, protocol = "tcp" },
      { containerPort = 9113, protocol = "tcp" }
    ]

    environment = [
      {
        name  = "BACKEND_URL"
        value = "http://backend.${var.namespace_name}:5000"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "frontend"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = local.backend_image
    essential = true

    portMappings = [
      { containerPort = 5000, protocol = "tcp" }
    ]

    environment = [
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "ecomm" },
      { name = "DB_USER", value = var.db_username },
      { name = "DB_PASSWORD", value = var.db_password },
      { name = "STRIPE_SECRET_KEY", value = var.stripe_secret_key },
      { name = "STRIPE_WEBHOOK_SECRET", value = var.stripe_webhook_secret }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "backend"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.project_name}-prometheus"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.prometheus_task.arn

  container_definitions = jsonencode([{
    name      = "prometheus"
    image     = local.prometheus_image
    essential = true

    portMappings = [
      { containerPort = 9090, protocol = "tcp" },
      { containerPort = 9106, protocol = "tcp" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "prometheus"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name      = "grafana"
    image     = local.grafana_image
    essential = true

    portMappings = [
      { containerPort = 3000, protocol = "tcp" }
    ]

    environment = [
      { name = "GF_SECURITY_ADMIN_USER", value = var.grafana_admin_user },
      { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_admin_password },
      { name = "PROMETHEUS_URL", value = "http://prometheus.${var.namespace_name}:9090" },
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_NAME", value = "ecomm" },
      { name = "DB_USER", value = var.db_username },
      { name = "DB_PASSWORD", value = var.db_password }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "grafana"
      }
    }
  }])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_a_id, var.public_subnet_b_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.frontend.arn
  }

}

resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_a_id, var.public_subnet_b_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }
}

resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_a_id, var.public_subnet_b_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = var.prometheus_target_group_arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  service_registries {
    registry_arn = aws_service_discovery_service.prometheus.arn
  }

}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_a_id, var.public_subnet_b_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = var.grafana_target_group_arn
    container_name   = "grafana"
    container_port   = 3000
  }

  service_registries {
    registry_arn = aws_service_discovery_service.grafana.arn
  }

}

resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Frontend from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "Grafana from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "Prometheus from ALB"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description = "Internal ECS traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
