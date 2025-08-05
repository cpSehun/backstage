variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "${{ values.awsRegion }}"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "${{ values.name }}"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "${{ values.instanceType }}"
}

variable "key_name" {
  description = "EC2 Key Pair name (must exist in AWS)"
  type        = string
  # This will be provided via terraform.tfvars or environment variable
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "${{ values.databaseInstanceType }}"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}