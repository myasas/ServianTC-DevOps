terraform {
  required_version = "~> 0.0"
  backend "s3" {}

required_providers {
    external = {
      source  = "external"
      version = "~> 2.0"
    }
  

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

module "storage" {
  source = "./modules/storage"

  short_name   = var.short_name
  default_tags = var.default_tags

  vpc_id                 = module.network.vpc_id
  vpc_az_size            = var.vpc_az_size
  vpc_subnet_storage_ids = module.network.vpc_subnet_storage_ids

  storage_instance_class = var.storage_instance_class

  security_group_storage_id = module.security.security_group_storage_id
}

module "bastion" {
  source = "./modules/bastion"

  short_name   = var.short_name
  default_tags = var.default_tags

  vpc_subnet_public_ids     = module.network.vpc_subnet_public_ids
  security_group_bastion_id = module.security.security_group_bastion_id

  bastion_allowed_port = var.bastion_allowed_port
}

module "eks" {
  source = "./modules/eks"

  short_name   = var.short_name
  default_tags = var.default_tags

  eks_version = var.eks_version

  vpc_subnet_public_ids  = module.network.vpc_subnet_public_ids
  vpc_subnet_private_ids = module.network.vpc_subnet_private_ids

  security_group_bastion_id     = module.security.security_group_bastion_id
  security_group_eks_cluster_id = module.security.security_group_eks_cluster_id
  security_group_front_id       = module.security.security_group_front_id

  eks_arn_user_list_with_masters_role  = var.eks_arn_user_list_with_masters_role
  eks_arn_user_list_with_readonly_role = var.eks_arn_user_list_with_readonly_role
}

module certificate {
  source = "./modules/certificate"

  # cert_dns_name = var.cert_dns_name
  # cert_org_name = var.cert_org_name
}


module "post-config" {
  source = "./modules/post-config"

  short_name   = var.short_name
  default_tags = var.default_tags

  bastion_name         = module.bastion.name
  bastion_private_key  = module.bastion.private_key
  bastion_allowed_port = var.bastion_allowed_port

  domain_name = var.domain_name

  vpc_id                              = module.network.vpc_id
  eks_cluster_name                    = module.eks.eks_cluster_name
  eks_fargate_profile_id              = module.eks.eks_fargate_profile_id
  eks_node_role_arn                   = module.eks.eks_node_role_arn
  eks_fargate_role_arn                = module.eks.eks_fargate_role_arn
  eks_external_dns_role_arn           = module.eks.eks_external_dns_role_arn
  eks_lb_controller_role_arn          = module.eks.eks_lb_controller_role_arn
  eks_k8s_masters_role_arn            = module.eks.eks_k8s_masters_role_arn
  eks_k8s_readonly_role_arn           = module.eks.eks_k8s_readonly_role_arn
  eks_arn_user_list_with_masters_user = var.eks_arn_user_list_with_masters_user

  eks_alb_ing_ssl_cert_arn            = module.certificate.alb_ing_ssl_cert_arn
  app_backend_db_host                 = module.storage.rds_address
  app_backend_db_port                 = module.storage.rds_port
  app_backend_db_user                 = base64encode(module.storage.rds_username_root_value)
  app_backend_db_password             = base64encode(module.storage.rds_password_root_value)
}

