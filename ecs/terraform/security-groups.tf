resource "aws_security_group" "alb" {
  name="${var.project_name}-alb-sg" vpc_id=aws_vpc.ecs.id
  ingress { from_port=80 to_port=80 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_security_group" "ecs" {
  name="${var.project_name}-ecs-sg" vpc_id=aws_vpc.ecs.id
  ingress { from_port=80 to_port=80 protocol="tcp" security_groups=[aws_security_group.alb.id] }
  ingress { from_port=5000 to_port=5000 protocol="tcp" security_groups=[aws_security_group.ecs.id] }
  ingress { from_port=9090 to_port=9090 protocol="tcp" security_groups=[aws_security_group.alb.id,aws_security_group.ecs.id] }
  ingress { from_port=3000 to_port=3000 protocol="tcp" security_groups=[aws_security_group.alb.id,aws_security_group.ecs.id] }
  ingress { from_port=9113 to_port=9113 protocol="tcp" security_groups=[aws_security_group.ecs.id] }
  ingress { from_port=9106 to_port=9106 protocol="tcp" security_groups=[aws_security_group.ecs.id] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_security_group" "rds" {
  name="${var.project_name}-rds-sg" vpc_id=aws_vpc.ecs.id
  ingress { from_port=3306 to_port=3306 protocol="tcp" security_groups=[aws_security_group.ecs.id] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}
