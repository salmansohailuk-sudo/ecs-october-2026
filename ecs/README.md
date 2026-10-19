# ECS October 2026

Two stages:
- Stage 1: VPC, RDS, ECR, ALB, security groups, builder EC2.
- Stage 2: ECS cluster and services (run on the builder EC2).

## Stage 1 - infrastructure + ALB

Push this repo to GitHub first (the builder EC2 clones it), then:

```bash
cd ecs/terraform/01-infrastructure
terraform init
terraform apply
```

## Get the Stage 1 values

Run this in the same place you ran Stage 1:

```bash
cd ecs
./get-stage1-values.sh
```

It prints a list of values. Keep them, you paste them into Stage 2 below.

## Connect to the builder EC2

AWS Console -> EC2 -> builder -> Connect -> EC2 Instance Connect.
Wait until this file exists:

```bash
ls ~/ecs-october-2026/READY
cd ~/ecs-october-2026/ecs
```

## Prepare database and images (on builder EC2)

```bash
export RDS_ENDPOINT="paste db_endpoint here"
export DB_PASSWORD="Cloud123"
./initialize-database.sh
./build-images.sh
./push-images.sh
```

## Stage 2 - ECS (on builder EC2)

```bash
cd ~/ecs-october-2026/ecs/terraform/02-ecs
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars      # paste the Stage 1 values, set the Stripe keys and Grafana password
terraform init
terraform apply
```

The app, Grafana (port 3000) and Prometheus (port 9090) URLs are printed at the end.

## Destroy

1. On the builder EC2: `terraform destroy` in `02-ecs`
2. Where you ran Stage 1: `terraform destroy` in `01-infrastructure`

## Notes

- Testing only: Fargate in public subnets, open ALB ports, builder EC2 has AdministratorAccess.
- Never commit `terraform.tfvars`.
