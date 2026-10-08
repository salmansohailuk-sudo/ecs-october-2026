resource "aws_security_group" "builder" {
  name   = "${var.project_name}-builder-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "EC2 Instance Connect / SSH for testing"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = aws_vpc.main.id

  # Testing setup: allow MySQL from this VPC so both the builder EC2
  # and ECS Fargate tasks can initialise/use the database.
  ingress {
    description = "MySQL from project VPC"
    from_port   = 3306
    to_port     = 3306
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
