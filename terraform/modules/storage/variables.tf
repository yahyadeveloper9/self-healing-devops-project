variable "resume_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the resume"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
}
