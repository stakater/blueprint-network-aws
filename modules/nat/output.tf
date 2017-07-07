output "nat_gateway_ids" {
  value = "${join(",", aws_nat_gateway.nat.*.id)}"
}

output "public_ip" {
  value = "${aws_eip.nat.public_ip}"
}
