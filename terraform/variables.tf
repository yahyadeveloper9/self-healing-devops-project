variable "aws_region" {
  type        = string
  description = "The AWS region to deploy infrastructure"
}

variable "project_name" {
  type        = string
  description = "The name of the project, used for naming resources"
  default     = "resume-platform"
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  type        = string
  description = "The AWS availability zone for the subnets"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type"
  default     = "t3.micro"
}

variable "key_pair_name" {
  type        = string
  description = "The name of the SSH key pair to attach to the EC2 instance"
}

variable "admin_cidr" {
  type        = string
  description = "The CIDR block allowed to SSH into the EC2 instance"
}

variable "resume_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the resume"
}
