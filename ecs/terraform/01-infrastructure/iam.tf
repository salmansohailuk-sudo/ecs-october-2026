resource "aws_iam_role" "builder" {
  name = "${var.project_name}-builder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "builder_ecr" {
  name = "${var.project_name}-builder-ecr"
  role = aws_iam_role.builder.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "builder" {
  name = "${var.project_name}-builder-profile"
  role = aws_iam_role.builder.name
}

# The builder EC2 runs Terraform for Stage 2 (ECS, IAM roles, Cloud Map, logs).
# AdministratorAccess keeps the test setup simple - tighten for anything real.
resource "aws_iam_role_policy_attachment" "builder_admin" {
  role       = aws_iam_role.builder.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
