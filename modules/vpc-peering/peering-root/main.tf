resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  peer_owner_id = "${var.target_owner_id}"
  peer_vpc_id = "${var.target_vpc_id}"
  vpc_id = "${var.root_vpc_id}"
  auto_accept = "true"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route" "root_to_target_private_route" {
  count = "${var.root_route_table_ids_count}" # https://github.com/hashicorp/terraform/issues/3888
  route_table_id = "${element(split(",", var.root_route_table_ids), count.index)}"
  destination_cidr_block = "${var.target_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}