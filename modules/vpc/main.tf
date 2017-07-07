resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.name}"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
}
