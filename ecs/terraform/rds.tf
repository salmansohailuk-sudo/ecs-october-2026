resource "aws_db_subnet_group" "ecs" {
  name="${var.project_name}-db-subnet-group"
  subnet_ids=[aws_subnet.public_a.id,aws_subnet.public_b.id]
}
resource "aws_db_instance" "mysql" {
  identifier="${var.project_name}-db"
  engine="mysql" instance_class="db.t3.micro" allocated_storage=20
  username=var.db_username password=var.db_password db_name="ecomm"
  publicly_accessible=false
  vpc_security_group_ids=[aws_security_group.rds.id]
  db_subnet_group_name=aws_db_subnet_group.ecs.name
  skip_final_snapshot=true
}
