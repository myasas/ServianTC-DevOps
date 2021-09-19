variable "short_name" {
}

variable "default_tags" {
  type = map(string)
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

variable "nat_gateway_size" {
}
