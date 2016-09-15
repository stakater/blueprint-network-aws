resource "aws_route" "peer_to_root_private_route" {
  count = "${var.target_route_table_ids_count}" # https://github.com/hashicorp/terraform/issues/3888"
  route_table_id = "${element(split(",", var.target_route_table_ids), count.index)}"
  destination_cidr_block = "${var.root_vpc_cidr}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
}