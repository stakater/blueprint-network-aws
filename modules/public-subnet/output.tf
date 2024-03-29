output "subnet_ids" {
  value = join(",", aws_subnet.public.*.id)
}

output "route_table_ids" {
  value = join(",", aws_route_table.public.*.id)
}
