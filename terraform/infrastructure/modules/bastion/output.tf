output "name" {
  value = "${var.short_name}-bastion"
}

output "private_key" {
  value = aws_ssm_parameter.private_key_pem.value
}
