data "aws_availability_zones" "available" {
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"
  assign_generated_ipv6_cidr_block = "true"

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-vpc"
  })
}

resource "aws_cloudwatch_log_group" "my_vpc_log_group" {
  name = "/aws/vpc/${var.short_name}/"

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-vpc-log"
  })
}

resource "aws_flow_log" "my_vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.my_vpc_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.my_vpc.id
}
