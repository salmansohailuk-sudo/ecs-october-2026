resource "aws_instance" "builder" {
  # Same AMI as the working EC2 project (Amazon Linux 2, us-east-1).
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.builder.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.builder.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    yum update -y
    yum install -y docker git mariadb yum-utils

    # Terraform (needed to run Stage 2 on this server)
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y terraform

    systemctl enable docker
    systemctl start docker
    usermod -aG docker ec2-user

    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    cd /home/ec2-user
    if [ ! -d /home/ec2-user/ecs-october-2026 ]; then
      git clone https://github.com/salmansohailuk-sudo/ecs-october-2026.git /home/ec2-user/ecs-october-2026
    fi

    chown -R ec2-user:ec2-user /home/ec2-user/ecs-october-2026
    chmod +x /home/ec2-user/ecs-october-2026/ecs/*.sh
    touch /home/ec2-user/ecs-october-2026/READY
  EOF

  tags = {
    Name = "${var.project_name}-docker-builder"
  }
}
