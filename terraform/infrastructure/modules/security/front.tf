resource "aws_security_group" "front" {
  name   = "${var.short_name}-front-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = "${var.short_name}-front-sg"
  })

  description = "Auto assigned by code."
}

resource "aws_security_group_rule" "front_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.front.id

  description = "Auto assigned by code."
}

resource "aws_security_group_rule" "front_443" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.front.id

  description = "Auto assigned by code."
}

