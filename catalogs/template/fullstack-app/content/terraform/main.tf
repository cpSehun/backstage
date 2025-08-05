locals {
  common_tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
    CreatedBy   = "backstage-template"
    Application = "${{ values.name }}"
  }
}

# 랜덤 비밀번호 생성
resource "random_password" "db_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# AWS Secrets Manager에 저장
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_name}-db-password"
  description = "Database password for ${var.project_name}"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  
  public_subnets = {
    "${{ values.awsRegion }}a" = "10.0.1.0/24"
    "${{ values.awsRegion }}b" = "10.0.2.0/24"
  }
  
  private_subnets = {
    "${{ values.awsRegion }}a" = "10.0.10.0/24"
    "${{ values.awsRegion }}b" = "10.0.20.0/24"
  }
  
  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"
  
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = random_password.db_password.result
  db_instance_class = var.db_instance_class
  
  tags = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"
  
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  
  instance_type = var.instance_type
  key_name      = var.key_name
  
  rds_endpoint = module.rds.rds_endpoint
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = random_password.db_password.result
  
  tags = local.common_tags
}
