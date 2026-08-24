data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web_role" {
  name               = "${var.project_name}-web-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "s3_read_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.resume_bucket_arn,
      "${var.resume_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "${var.project_name}-s3-read-policy-${var.environment}"
  description = "Allows EC2 instance to read from the resume S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_access.json
}

resource "aws_iam_role_policy_attachment" "web_s3_attach" {
  role       = aws_iam_role.web_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "${var.project_name}-web-profile-${var.environment}"
  role = aws_iam_role.web_role.name
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : null
  iam_instance_profile        = aws_iam_instance_profile.web_profile.name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = <<-EOF
              yum update -y || apt-get update -y
              EOF

  tags = {
    Name = "${var.project_name}-web-${var.environment}"
  }
}
