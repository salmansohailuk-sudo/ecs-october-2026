# ECS October 2026

Standalone ECS test project. This project is independent from the existing EC2 Docker Compose project.

## Deployment order

### 1. Create base infrastructure

```bash
cd terraform/01-infrastructure
terraform init
terraform apply
```

This creates the VPC, public subnets, ECR repositories, RDS MySQL, builder EC2 and IAM permissions. It does NOT create ECS.

### 2. Connect to the builder EC2

Use AWS Console -> EC2 -> Instances -> Connect -> EC2 Instance Connect.

```bash
cd /home/ec2-user/ecs-october-2026/ecs
```

### 3. Build images

No Docker Compose is used.

```bash
./build-images.sh
```

### 4. Push images to ECR

```bash
./push-images.sh
```

Images:
- ecomm-ecs-frontend
- ecomm-ecs-backend
- monitoring-ecs-prometheus
- monitoring-ecs-grafana

### 5. Initialise RDS

```bash
./initialize-database.sh
```

This runs createdatabase.sql against the RDS MySQL database.

### 6. Create ECS

Only after the images are in ECR and the database has been initialised:

```bash
cd terraform/02-ecs
terraform init
terraform apply
```

This creates the ECS cluster, Cloud Map service discovery, ALB, task definitions and ECS services.

## Important

There is intentionally:
- no SSH key pair
- no SSM / Session Manager
- no Docker Compose in this ECS project
- no nginx exporter ECR repository
- no CloudWatch exporter ECR repository

The nginx exporter is baked into the frontend image.
The CloudWatch exporter is baked into the Prometheus image.

The builder EC2 is only for building and pushing images. The application and monitoring run on ECS Fargate.
