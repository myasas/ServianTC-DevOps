resource "tls_private_key" "my_tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "private_key_pem" {
  name  = "/${var.short_name}/ssh/bastion/private_key_pem"
  type  = "SecureString"
  value = tls_private_key.my_tls.private_key_pem

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "public_key_pem" {
  name  = "/${var.short_name}/ssh/bastion/public_key_pem"
  type  = "SecureString"
  value = tls_private_key.my_tls.public_key_pem

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "public_key_openssh" {
  name  = "/${var.short_name}/ssh/bastion/public_key_openssh"
  type  = "SecureString"
  value = tls_private_key.my_tls.public_key_openssh

  tags = merge(var.default_tags, {})
}
