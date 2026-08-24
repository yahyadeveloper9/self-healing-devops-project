variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "admin_cidr" {
  type        = string
  description = "The CIDR block allowed to SSH into the EC2 instance"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
}
