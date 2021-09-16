variable "short_name" {
}

variable "default_tags" {
  type = map(string)
}

variable "vpc_id" {
}

variable "vpc_az_size" {
}

variable "vpc_subnet_storage_ids" {
  type = list(string)
}

variable "security_group_storage_id" {
}

variable "storage_instance_class" {
}
