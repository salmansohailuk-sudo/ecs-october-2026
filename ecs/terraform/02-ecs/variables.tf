variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecs-october-2026"
}

variable "namespace_name" {
  type    = string
  default = "testcluster.local"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "Cloud123"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_a_id" {
  type = string
}

variable "public_subnet_b_id" {
  type = string
}

variable "ecr_frontend" {
  type = string
}

variable "ecr_backend" {
  type = string
}

variable "ecr_prometheus" {
  type = string
}

variable "ecr_grafana" {
  type = string
}

variable "db_endpoint" {
  type = string
}
