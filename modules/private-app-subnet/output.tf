output "subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}

output "route_table_ids" {
  value = "${join(",", aws_route_table.private.*.id)}"
}
