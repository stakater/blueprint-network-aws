resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  count         = "${length(var.peer_vpc_id) > 0 ? 1 : 0}"
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.root_vpc_id}"
  auto_accept   = "true"

  tags {
    Name = "${var.name}-px"
  }
}

resource "aws_route" "root_to_peer_private_route" {
  count                     = "${length(var.peer_vpc_id) > 0 ? var.root_route_table_ids_count : 0}"
  route_table_id            = "${element(split(",", var.root_route_table_ids), count.index)}"
  destination_cidr_block    = "${var.peer_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}

resource "aws_route" "peer_to_root_private_route" {
  count                     = "${length(var.peer_vpc_id) > 0 ? var.root_route_table_ids_count : 0}" # https://github.com/hashicorp/terraform/issues/3888"
  route_table_id            = "${element(split(",", var.peer_route_table_ids), count.index)}"
  destination_cidr_block    = "${var.root_vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}
