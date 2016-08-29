resource "aws_route_table" "persistance" {
    vpc_id = "${var.vpc_id}"

    tags {
      Name = "${var.name}-RT"
    }
}

resource "aws_subnet" "persistance" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_persistance_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.azs)}"

  tags {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}

resource "aws_route_table_association" "persistance" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.persistance.*.id, count.index)}"
  route_table_id = "${aws_route_table.persistance.id}"
}