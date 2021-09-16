
variable "eks_version" {
}

variable "vpc_cidr" {
}

variable "vpc_subnet_public_cidr" {
  type = list(string)
}

variable "vpc_subnet_private_cidr" {
  type = list(string)
}

variable "vpc_az_size" {
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
