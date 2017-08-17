resource "aws_eip" "nat" {
  vpc = true

  count = "${length(var.azs)}" # Comment out count to only have 1 NAT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${length(var.azs)}" # Comment out count to only have 1 NAT

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(split(",", var.public_subnet_ids), count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}
