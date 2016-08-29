variable "vpc_name" { default = "vpc" }
variable "vpc_cidr" { }

resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags {
        Name = "${var.name}"
    }
    enable_dns_support = true
    enable_dns_hostnames = true
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
    value = "${aws_vpc.vpc.cidr_block}"
}
