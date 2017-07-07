resource "aws_route_table" "persistence" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}-RT"
  }
}

resource "aws_subnet" "persistence" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_persistence_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.azs)}"

  tags {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}

resource "aws_route_table_association" "persistence" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.persistence.*.id, count.index)}"
  route_table_id = "${aws_route_table.persistence.id}"
}
