resource "aws_s3_bucket" "resume" {
  bucket = var.resume_bucket_name

  tags = {
    Name = "${var.project_name}-resume-${var.environment}"
  }
}

resource "aws_s3_bucket_public_access_block" "resume_access" {
  bucket                  = aws_s3_bucket.resume.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "resume_encryption" {
  bucket = aws_s3_bucket.resume.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "resume_pdf" {
  bucket = aws_s3_bucket.resume.id
  key    = "YahyaShaikhResume.pdf"
  source = "${path.root}/../resume/YahyaShaikhResume.pdf"
  etag   = filemd5("${path.root}/../resume/YahyaShaikhResume.pdf")
}

