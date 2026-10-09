# ECS October 2026

Standalone ECS test project. It is independent from the existing EC2 Docker application.

The builder EC2 only builds Docker images, pushes them to ECR and can initialise RDS. The application and monitoring run on ECS Fargate.

## Deployment order

### Stage 1 - infrastructure

```bash
cd ecs/terraform/01-infrastructure
terraform init
terraform apply
```

Creates:
- VPC and two public subnets
- Internet Gateway and public routes
- RDS MySQL
- Four ECR repositories
- Builder EC2 with Docker, Docker Compose, AWS CLI, Git and MySQL client
- Builder IAM role#
- ALB

It does NOT create ECS.

### Connect to builder EC2

AWS Console -> EC2 -> Instances -> select the builder -> Connect -> EC2 Instance Connect.

Then:

```bash
cd /home/ec2-user/ecs-october-2026/ecs
```

### Stage 1a - initialise database

```bash
export RDS_ENDPOINT="$(cd terraform/01-infrastructure && terraform output -raw db_endpoint)"
export DB_PASSWORD="Cloud123"
./initialize-database.sh
```

### Stage 1b - build images

Docker Compose is used only to build the images. It does not start the application.

```bash
./build-images.sh
```

### Stage 1c - push images

```bash
./push-images.sh
```

Four images are pushed:
- ecomm-ecs-frontend
- ecomm-ecs-backend
- monitoring-ecs-prometheus
- monitoring-ecs-grafana

### Stage 1d - Copy  ALB URL to Webhook

```bash

```

### Stage 2 - ECS

First collect Stage 1 outputs:

```bash
cd terraform/01-infrastructure
terraform output
```

Copy the VPC, subnet, ALB, ECR and DB endpoint values into:

```text
terraform/02-ecs/terraform.tfvars
```

Create it from the example:

```bash
cd ../02-ecs
terraform.tfvars
```

Set:
- vpc_id
- public_subnet_a_id
- public_subnet_b_id
- ecr_frontend
- ecr_backend
- ecr_prometheus
- ecr_grafana
- db_endpoint
- db_password
- stripe_secret_key
- stripe_webhook_secret
- grafana_admin_password

Then:

```bash
terraform init
terraform apply
```

## Runtime architecture

```text
Internet
   |
   v
 ALB
   |-- :80   -> Frontend/Nginx -> Backend
   |-- :3000 -> Grafana
   `-- :9090 -> Prometheus

ECS Cloud Map namespace:
  testcluster.local

backend.testcluster.local:5000
prometheus.testcluster.local:9090
frontend.testcluster.local:9113
```

Nginx exporter is baked into the frontend image.
CloudWatch exporter is baked into the Prometheus image.

There are no separate ECR repositories for either exporter.

## Check prometheus

- Prometheus targets:

http://ecs-october-2026-alb-1732281227.us-east-1.elb.amazonaws.com:9090/targets

- Prometheus query API example (checks whether Prometheus is responding):

http://ecs-october-2026-alb-1732281227.us-east-1.elb.amazonaws.com:9090/api/v1/query?query=up


## Important

- No EC2 key pair is required.
- No SSM Session Manager is required.
- No NAT Gateway is used.
- ECS Fargate tasks run in public subnets with public IPs for this testing setup.
- Do not commit `terraform.tfvars` or secrets.
- The existing EC2 project is not modified by this project.
