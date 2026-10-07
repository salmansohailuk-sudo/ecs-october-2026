# Independent ECS environment

This directory is completely separate from the existing EC2 deployment.

EC2 files are not referenced by these Terraform files.

Architecture:
- ECS Fargate
- public subnets
- Internet Gateway
- NO NAT Gateway
- ALB
- Cloud Map namespace: testcluster.local
- frontend = NGINX + nginx-prometheus-exporter
- backend = Flask
- prometheus = Prometheus + CloudWatch exporter
- grafana = Grafana
- separate ECS RDS

## Deploy

cd ecs/terraform
terraform init
terraform plan
terraform apply

Then:

cd ..
chmod +x build-images.sh push-images.sh
./build-images.sh
./push-images.sh

Then force ECS services to pull the latest images:

aws ecs update-service --cluster ecomm-ecs-cluster --service frontend --force-new-deployment
aws ecs update-service --cluster ecomm-ecs-cluster --service backend --force-new-deployment
aws ecs update-service --cluster ecomm-ecs-cluster --service prometheus --force-new-deployment
aws ecs update-service --cluster ecomm-ecs-cluster --service grafana --force-new-deployment

Get URLs:

cd terraform
terraform output frontend_url
terraform output prometheus_url
terraform output grafana_url

Destroy ECS only:

terraform destroy
