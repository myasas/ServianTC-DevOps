variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "eks_version" {
}

variable "vpc_subnet_public_ids" {
  type = list(string)
}

variable "vpc_subnet_private_ids" {
  type = list(string)
}

variable "security_group_eks_cluster_id" {
}

variable "security_group_bastion_id" {
}

variable "security_group_front_id" {
}