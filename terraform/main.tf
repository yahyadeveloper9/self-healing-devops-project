module "network" {
  source = "./modules/network"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  project_name        = var.project_name
  environment         = var.environment
}

module "security" {
  source = "./modules/security"

  vpc_id       = module.network.vpc_id
  admin_cidr   = var.admin_cidr
  project_name = var.project_name
  environment  = var.environment
}

module "storage" {
  source = "./modules/storage"

  resume_bucket_name = var.resume_bucket_name
  project_name       = var.project_name
  environment        = var.environment
}

module "compute" {
  source = "./modules/compute"

  subnet_id         = module.network.public_subnet_id
  security_group_id = module.security.web_sg_id
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_pair_name     = var.key_pair_name
  resume_bucket_arn = module.storage.bucket_arn
  project_name      = var.project_name
  environment       = var.environment
}
