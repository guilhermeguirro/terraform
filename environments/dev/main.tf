terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-landingzone-010438463494"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-landingzone"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source          = "../../modules/networking"
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "security" {
  source = "../../modules/security"
  
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpn_cidr    = "172.16.0.0/16"  # Ajuste conforme sua necessidade
  vpc_1_cidr  = "10.1.0.0/16"    # Ajuste conforme sua necessidade
  vpc_2_cidr  = "10.2.0.0/16"    # Ajuste conforme sua necessidade
  stacksync_ips = [
    "192.168.1.0/32",  # Ajuste conforme sua necessidade
    "192.168.2.0/32"   # Ajuste conforme sua necessidade
  ]
}

module "database" {
  source = "../../modules/database"

  environment       = var.environment
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.security.aurora_security_group_id
  database_name     = "appdb"
  instance_class    = var.environment == "prod" ? "db.r6g.large" : "db.t4g.medium"
}

module "compute" {
  source = "../../modules/compute"

  environment       = var.environment
  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.security.ec2_security_group_id
  instance_type     = var.environment == "prod" ? "t3.medium" : "t3.micro"
}
