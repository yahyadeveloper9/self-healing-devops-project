output "bucket_name" {
  description = "The name of the resume S3 bucket"
  value       = aws_s3_bucket.resume.bucket
}

output "bucket_arn" {
  description = "The ARN of the resume S3 bucket"
  value       = aws_s3_bucket.resume.arn
}
