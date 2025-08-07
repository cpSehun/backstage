variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "${{ values.awsRegion }}"  # 템플릿에서 직접 설정
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  # 파이프라인에서 BITBUCKET_REPO_SLUG로 전달
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "${{ values.instanceType }}"  # 템플릿에서 직접 설정
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  # Repository 변수에서 전달
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "${{ values.databaseInstanceType }}"  # 템플릿에서 직접 설정
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

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  # 파이프라인에서 자동 생성하여 전달
}