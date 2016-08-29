variable "name" { default = "private-app" }
variable "vpc_id" { }
variable "nat_gateway_ids" { }

variable "private_subnets" {
  description = "A list of CIDR blocks for private subnets inside the VPC."
  default=[]
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default=[]
}

resource "aws_route_table" "private" {
	vpc_id = "${var.vpc_id}"
	count  = "${length(var.azs)}"

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
	}
	tags      { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.azs)}"

  tags {
    Name = "${var.name}-${var.azs[count.index]}"
  }
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

output "subnet_ids" {
	value = "${join(",", aws_subnet.private.*.id)}"
}