resource "aws_security_group" "bastion" {
  name   = "${var.short_name}-bastion-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-bastion-sg"
  })

  description = "Auto assigned by code."
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type        = "ingress"
  from_port   = var.bastion_allowed_port
  to_port     = var.bastion_allowed_port
  protocol    = "tcp"
  cidr_blocks = var.bastion_allowed_cidrs

  security_group_id = aws_security_group.bastion.id

  description = "Auto assigned by code."
}
