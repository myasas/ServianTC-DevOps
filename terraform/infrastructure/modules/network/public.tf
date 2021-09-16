resource "aws_subnet" "public" {
  count = var.vpc_az_size

  vpc_id = aws_vpc.my_vpc.id

  availability_zone               = data.aws_availability_zones.available.names[count.index]
  cidr_block                      = var.vpc_subnet_public_cidr[count.index]
  assign_ipv6_address_on_creation = false

  tags = merge(var.default_tags, {
    "Name"                                    = "${var.short_name}-subnet-public-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/${var.short_name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  })
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(var.default_tags, {
    "Name" = "${var.short_name}-public-rt"
  })
}

resource "aws_route" "public_route_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route_table_association" "public_assoc" {
  count = var.vpc_az_size

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
