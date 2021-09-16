resource "aws_security_group" "storage" {
  name   = "${var.short_name}-storage-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = "${var.short_name}-storage-sg"
  })

  description = "Auto assigned by code."
}

resource "aws_security_group_rule" "storage_ingress_5432" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = var.vpc_subnet_private_cidr

  security_group_id = aws_security_group.storage.id

  description = "Auto assigned by code."
}
