output "efs_id" {
  value = aws_efs_file_system.storage_nfs.id
}

output "rds_address" {
  value = aws_db_instance.storage_db_instance.address
}

output "rds_port" {
  value = aws_db_instance.storage_db_instance.port
}

output "rds_username_root_arn" {
  value = aws_ssm_parameter.rds_my_username_root.arn
}

output "rds_password_root_arn" {
  value = aws_ssm_parameter.rds_my_password_root.arn
}

output "rds_username_root_value" {
  value = aws_ssm_parameter.rds_my_username_root.value
}

output "rds_password_root_value" {
  value = aws_ssm_parameter.rds_my_password_root.value
}
