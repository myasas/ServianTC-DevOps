terraform {
  required_version = "~> 0.0"
  backend "s3" {}

required_providers {
  

    aws= {
      source  = "aws"
      version = "~> 3.0"
    }
  }
}

module "network" {
  source = "./modules/network"

  short_name   = var.short_name
  default_tags = var.default_tags

  vpc_cidr    = var.vpc_cidr
  vpc_az_size = var.vpc_az_size

  nat_gateway_size = var.nat_gateway_size

  vpc_subnet_public_cidr  = var.vpc_subnet_public_cidr
  vpc_subnet_private_cidr = var.vpc_subnet_private_cidr
  vpc_subnet_storage_cidr = var.vpc_subnet_storage_cidr
}

module "security" {
  source = "./modules/security"

  short_name   = var.short_name
  default_tags = var.default_tags

  vpc_id                  = module.network.vpc_id
  vpc_cidr                = var.vpc_cidr
  vpc_subnet_private_cidr = var.vpc_subnet_private_cidr

  bastion_allowed_port  = var.bastion_allowed_port
  bastion_allowed_cidrs = var.bastion_allowed_cidrs
}

module "bastion" {
  source = "./modules/bastion"

  short_name   = var.short_name
  default_tags = var.default_tags

  vpc_subnet_public_ids     = module.network.vpc_subnet_public_ids
  security_group_bastion_id = module.security.security_group_bastion_id

  bastion_allowed_port = var.bastion_allowed_port
}