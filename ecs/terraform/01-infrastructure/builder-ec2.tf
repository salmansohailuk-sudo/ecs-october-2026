data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "builder" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.builder.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.builder.name

  # Deliberately no key_name.
  # Connect using EC2 Instance Connect from the AWS Console.

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker git awscli mariadb105

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user

    mkdir -p /home/ec2-user
    cd /home/ec2-user

    if [ ! -d /home/ec2-user/ecs-october-2026 ]; then
      git clone https://github.com/salmansohailuk-sudo/ecs-october-2026.git /home/ec2-user/ecs-october-2026
    fi

    chown -R ec2-user:ec2-user /home/ec2-user/ecs-october-2026
    chmod +x /home/ec2-user/ecs-october-2026/ecs/*.sh
  EOF

  tags = {
    Name = "${var.project_name}-docker-builder"
  }
}
