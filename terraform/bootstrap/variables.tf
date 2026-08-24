variable "aws_region" {
  type        = string
  description = "The AWS region to deploy infrastructure"
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "resume-platform"
}
