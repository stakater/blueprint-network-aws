output "nat_gateway_ids" {
  value = "${join(",", aws_nat_gateway.nat.*.id)}"
}