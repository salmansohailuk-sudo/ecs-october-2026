resource "aws_vpc" "ecs" {
  cidr_block=var.vpc_cidr
  enable_dns_support=true
  enable_dns_hostnames=true
  tags={Name="${var.project_name}-vpc"}
}
resource "aws_internet_gateway" "ecs" { vpc_id=aws_vpc.ecs.id }
resource "aws_route_table" "public" {
  vpc_id=aws_vpc.ecs.id
  route { cidr_block="0.0.0.0/0" gateway_id=aws_internet_gateway.ecs.id }
}
resource "aws_subnet" "public_a" {
  vpc_id=aws_vpc.ecs.id cidr_block=var.public_subnet_a_cidr
  availability_zone="${var.aws_region}a" map_public_ip_on_launch=true
}
resource "aws_subnet" "public_b" {
  vpc_id=aws_vpc.ecs.id cidr_block=var.public_subnet_b_cidr
  availability_zone="${var.aws_region}b" map_public_ip_on_launch=true
}
resource "aws_route_table_association" "a" { subnet_id=aws_subnet.public_a.id route_table_id=aws_route_table.public.id }
resource "aws_route_table_association" "b" { subnet_id=aws_subnet.public_b.id route_table_id=aws_route_table.public.id }
