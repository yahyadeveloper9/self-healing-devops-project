output "terraform_state_bucket_name" {
  description = "The name of the created S3 bucket for Terraform state. Use this in your backend.tf."
  value       = aws_s3_bucket.terraform_state.bucket
}
