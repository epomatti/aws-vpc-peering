resource "aws_iam_instance_profile" "windows" {
  name = "windows-${var.workload}-intance-profile"
  role = aws_iam_role.windows.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "windows-deployer-key"
  public_key = file("${path.module}/../../keys/temp_key.pub")
}

resource "aws_instance" "windows" {
  ami           = "ami-060b1c20c93e475fd"
  instance_type = var.instance_type

  associate_public_ip_address = true
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.windows.id]

  availability_zone    = var.az
  iam_instance_profile = aws_iam_instance_profile.windows.id
  # user_data            = file("${path.module}/userdata.sh")

  key_name = aws_key_pair.deployer.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = false
  ebs_optimized = false

  root_block_device {
    encrypted = true
  }

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address,
      user_data
    ]
  }

  tags = {
    Name = "windows-${var.workload}"
  }
}

### IAM Role ###

resource "aws_iam_role" "windows" {
  name = "Custom${var.workload}Windows"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.windows.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "windows" {
  name        = "ec2-ssm-windows-${var.workload}"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ssm-windows-${var.workload}"
  }
}

resource "aws_security_group_rule" "rdp" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.windows.id
}

resource "aws_security_group_rule" "http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.windows.id
}

resource "aws_security_group_rule" "https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.windows.id
}

resource "aws_security_group_rule" "mysql" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.windows.id
}
