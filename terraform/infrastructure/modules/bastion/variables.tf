variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "vpc_subnet_public_ids" {
  type = list(string)
}

variable "security_group_bastion_id" {
}

variable "bastion_allowed_port" {
  type = string
}
