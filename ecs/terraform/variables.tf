variable "aws_region" { type=string default="us-east-1" }
variable "project_name" { type=string default="ecomm-ecs" }
variable "namespace_name" { type=string default="testcluster.local" }
variable "vpc_cidr" { type=string default="10.20.0.0/16" }
variable "public_subnet_a_cidr" { type=string default="10.20.1.0/24" }
variable "public_subnet_b_cidr" { type=string default="10.20.2.0/24" }
variable "db_username" { type=string default="admin" sensitive=true }
variable "db_password" { type=string default="ChangeMe123!" sensitive=true }
