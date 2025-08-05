variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with AZ as key and CIDR as value"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of private subnets with AZ as key and CIDR as value"
  type        = map(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
