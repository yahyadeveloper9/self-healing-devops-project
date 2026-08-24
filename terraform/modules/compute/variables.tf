variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to launch the EC2 instance in"
}

variable "security_group_id" {
  type        = string
  description = "The ID of the security group to attach to the EC2 instance"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type"
}

variable "key_pair_name" {
  type        = string
  description = "The name of the SSH key pair to attach to the EC2 instance"
  default     = ""
}

variable "resume_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to allow read access to"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
}
