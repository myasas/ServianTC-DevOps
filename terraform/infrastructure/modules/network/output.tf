output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "vpc_owner_id" {
  value = aws_vpc.my_vpc.owner_id
}

output "vpc_subnet_public_ids" {
  value = aws_subnet.public.*.id
}

output "table_route_public_id" {
  value = aws_route_table.public.id
}

output "vpc_subnet_private_ids" {
  value = aws_subnet.private.*.id
}

output "table_route_private_for_az_ids" {
  value = aws_route_table.private_for_az.*.id
}

output "vpc_subnet_storage_ids" {
  value = aws_subnet.storage.*.id
}

output "table_route_storage_id" {
  value = aws_route_table.storage.id
}
