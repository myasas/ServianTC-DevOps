resource "random_password" "rds_my_password_root" {
  length           = 15
  special          = false
  override_special = "_%@"
}

resource "aws_ssm_parameter" "rds_my_username_root" {
  name  = "/${var.short_name}/rds/root/username"
  type  = "SecureString"
  value = "root"

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "rds_my_password_root" {
  name  = "/${var.short_name}/rds/root/password"
  type  = "SecureString"
  value = random_password.rds_my_password_root.result

  tags = merge(var.default_tags, {})
}
