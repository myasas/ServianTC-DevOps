variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "vpc_subnet_private_cidr" {
}

variable "bastion_allowed_port" {
  type = string
}

variable "bastion_allowed_cidrs" {
  type = list(string)
}
