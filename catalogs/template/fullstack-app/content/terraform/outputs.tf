output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "load_balancer_url" {
  description = "Load Balancer URL"
  value       = "http://${module.ec2.load_balancer_dns}"
}

output "load_balancer_dns" {
  description = "Load Balancer DNS name"
  value       = module.ec2.load_balancer_dns
}

output "database_password_secret_name" {
  description = "AWS Secrets Manager secret name for database password"
  value       = aws_secretsmanager_secret.db_password.name
}

output "database_password" {
  description = "Database password (use with caution)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "database_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_username}:${random_password.db_password.result}@${module.rds.rds_endpoint}:5432/${var.db_name}"
  sensitive   = true
}

output "application_urls" {
  description = "Application access URLs"
  value = {
    frontend    = "http://${module.ec2.load_balancer_dns}"
    backend_api = "http://${module.ec2.load_balancer_dns}/api"
    health      = "http://${module.ec2.load_balancer_dns}/health"
    docs        = "http://${module.ec2.load_balancer_dns}/docs"
  }
}

output "aws_resources" {
  description = "AWS resource information"
  value = {
    region            = var.aws_region
    vpc_id            = module.vpc.vpc_id
    rds_identifier    = module.rds.rds_identifier
    autoscaling_group = module.ec2.autoscaling_group_name
    load_balancer_arn = module.ec2.load_balancer_arn
  }
}
