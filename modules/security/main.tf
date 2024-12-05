resource "aws_security_group" "aurora" {
  name_prefix = "aurora-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for Aurora"

  # Ingress rule para EC2
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]
    description = "VPN access"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_1_cidr]
    description = "VPC 1 access"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_2_cidr]
    description = "VPC 2 access"
  }

  tags = {
    Name        = "aurora-sg-${var.environment}"
    Environment = var.environment
  }
}

# Security Group para EC2
resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg-"
  vpc_id      = var.vpc_id
  description = "Security group for EC2 jumphost"

  # SSH da VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpn_cidr]
    description = "SSH from VPN"
  }

  # SSH dos VPCs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_1_cidr, var.vpc_2_cidr]
    description = "SSH from VPCs"
  }

  # SSH do Stacksync
  dynamic "ingress" {
    for_each = var.stacksync_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "SSH from Stacksync"
    }
  }

  # Regra de egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "ec2-sg-${var.environment}"
    Environment = var.environment
  }
}
