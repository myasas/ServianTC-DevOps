variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "eks_version" {
}

variable "vpc_cidr" {
}

variable "vpc_az_size" {
}

variable "vpc_subnet_public_cidr" {
  type = list(string)
}

variable "vpc_subnet_private_cidr" {
  type = list(string)
}

variable "vpc_subnet_storage_cidr" {
  type = list(string)
}

variable "storage_instance_class" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "subdomain_names" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "eks_arn_user_list_with_masters_user" {
  type = list(string)
}

variable "eks_arn_user_list_with_masters_role" {
  type = list(string)
}

variable "eks_arn_user_list_with_readonly_role" {
  type = list(string)
}


variable "bastion_allowed_port" {
  type = string
}

variable "bastion_allowed_cidrs" {
  type = list(string)
}

variable "nat_gateway_size" {
  type = string
}

variable "cert_dns_name" {
  type = string
}

variable "cert_org_name" {
  type = string
}