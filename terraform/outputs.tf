output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.network.private_subnet_id
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.compute.public_ip
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.compute.private_ip
}

output "resume_bucket_name" {
  description = "The name of the resume S3 bucket"
  value       = module.storage.bucket_name
}

output "application_url" {
  description = "The URL to access the deployed resume application"
  value       = "http://${module.compute.public_ip}"
}
