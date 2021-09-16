variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "bastion_name" {
}

variable "bastion_private_key" {
}

variable "eks_cluster_name" {
}

variable "eks_fargate_profile_id" {
}

variable "eks_fargate_role_arn" {
}

variable "eks_node_role_arn" {
}

variable "eks_external_dns_role_arn" {
}

variable "eks_lb_controller_role_arn" {
}

variable "eks_k8s_masters_role_arn" {
}

variable "eks_k8s_readonly_role_arn" {
}

variable "eks_arn_user_list_with_masters_user" {
  type = list(string)
}

variable "vpc_id" {
}

variable "domain_name" {
}

variable "bastion_allowed_port" {
  type = string
}
