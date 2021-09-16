resource "aws_subnet" "private" {
  count = var.vpc_az_size

  vpc_id = aws_vpc.my_vpc.id

  availability_zone               = data.aws_availability_zones.available.names[count.index]
  cidr_block                      = var.vpc_subnet_private_cidr[count.index]
  assign_ipv6_address_on_creation = false

  tags = merge(var.default_tags, {
    "Name"                                    = "${var.short_name}-subnet-private-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/${var.short_name}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  })
}

resource "aws_route_table" "private_for_az" {
  count = var.vpc_az_size

  vpc_id = aws_vpc.my_vpc.id

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-private-${data.aws_availability_zones.available.names[count.index]}-rt"
  })
}

resource "aws_route_table_association" "private_for_az_assoc" {
  count = var.vpc_az_size

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_for_az.*.id, count.index)
}

## NAT GATEWAY

resource "aws_eip" "nat" {
  count = var.nat_gateway_size

  tags = merge(var.default_tags, {
    "Name"  = "${var.short_name}-eip"
    "Usage" = "by nat gateway"
  })
}

resource "aws_nat_gateway" "nat" {
  count = var.nat_gateway_size

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-nat-gateway-${data.aws_availability_zones.available.names[count.index]}"
  })
}

resource "aws_route" "nat_route_private_for_az" {
  count = length(aws_route_table.private_for_az.*.id)

  route_table_id         = element(aws_route_table.private_for_az.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, (var.nat_gateway_size - 1 >= count.index) ? count.index : var.nat_gateway_size - 1)
}
