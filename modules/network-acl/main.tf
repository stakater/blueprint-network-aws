resource "aws_network_acl" "acl" {
  vpc_id     = "${var.vpc_id}"
  subnet_ids = ["${concat(split(",", var.public_subnet_ids), split(",", var.private_app_subnet_ids))}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "${var.name}"
  }
}
