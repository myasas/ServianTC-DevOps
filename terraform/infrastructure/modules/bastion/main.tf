resource "aws_key_pair" "my_key_pair_bastion" {
  key_name   = "${var.short_name}-bastion"
  public_key = aws_ssm_parameter.public_key_openssh.value
}

data "aws_availability_zones" "available" {}
