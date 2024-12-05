terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Data source para obter a AMI mais recente do Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Gera um par de chaves SSH
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Armazena a chave SSH no Secrets Manager
resource "aws_secretsmanager_secret" "ec2_ssh_key" {
  name        = "ec2-ssh-key-${var.environment}"
  description = "SSH key for EC2 instance in ${var.environment}"

  tags = {
    Environment = var.environment
    Name        = "ec2-ssh-key-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "ec2_ssh_key" {
  secret_id = aws_secretsmanager_secret.ec2_ssh_key.id
  secret_string = jsonencode({
    private_key = tls_private_key.ec2.private_key_pem
    public_key  = tls_private_key.ec2.public_key_openssh
  })
}

# Cria o key pair no AWS
resource "aws_key_pair" "ec2" {
  key_name_prefix = "jumphost-${var.environment}"
  public_key      = tls_private_key.ec2.public_key_openssh

  tags = {
    Environment = var.environment
    Name        = "jumphost-key-${var.environment}"
  }
}

# EC2 Instance (JumpHost)
resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                   = aws_key_pair.ec2.key_name

  root_block_device {
    volume_size           = 20
    volume_type          = "gp2"
    encrypted            = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y postgresql15 git jq aws-cli
              EOF

  tags = {
    Name        = "jumphost-${var.environment}"
    Environment = var.environment
  }
}

# Elastic IP (removido o atributo domain)
resource "aws_eip" "jumphost" {
  instance = aws_instance.jumphost.id
  vpc      = true  # Usando vpc = true em vez de domain

  tags = {
    Name        = "jumphost-eip-${var.environment}"
    Environment = var.environment
  }
}
