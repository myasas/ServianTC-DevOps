resource "aws_db_subnet_group" "storage_db_group" {
  name       = "${var.short_name}-storage-db-group"
  subnet_ids = var.vpc_subnet_storage_ids

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-storage-db-group"
  })
}

resource "aws_db_parameter_group" "storage_db_parameter_group" {
  name        = "${var.short_name}-storage-db-parameter-group-preprod"
  description = "Custom parameters by RDS Postgres."
  family      = "postgres9.6"
  

  parameter {
    apply_method = "pending-reboot"
    name  = "max_connections"
    value = "100"
  }

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-storage-db-parameter-group"
  })
}

resource "aws_db_instance" "storage_db_instance" {
  db_subnet_group_name = aws_db_subnet_group.storage_db_group.name
  identifier           = "${var.short_name}-storage-db"

  allocated_storage    = "20"
  storage_type         = "gp2"
  storage_encrypted    = false
  engine               = "postgres"
  engine_version       = "9.6"
  instance_class       = var.storage_instance_class
  parameter_group_name = aws_db_parameter_group.storage_db_parameter_group.id

  username = aws_ssm_parameter.rds_my_username_root.value
  password = aws_ssm_parameter.rds_my_password_root.value
  port     = "5432"

  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = false

  vpc_security_group_ids = [var.security_group_storage_id]

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-storage-db"
  })

  lifecycle {
    ignore_changes = [username, password]
  }

  depends_on = [
    aws_ssm_parameter.rds_my_username_root,
    aws_ssm_parameter.rds_my_password_root
  ]
}
