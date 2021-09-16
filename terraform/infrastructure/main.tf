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
