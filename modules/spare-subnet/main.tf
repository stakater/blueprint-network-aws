resource "aws_subnet" "spare" {
  vpc_id            = var.vpc_id
  cidr_block        = var.spare_subnets[count.index]
  availability_zone = var.azs[count.index]
  count             = length(var.azs)

  tags {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}
