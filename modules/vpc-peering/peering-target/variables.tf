variable "target_route_table_ids" {
  description = "Comma-separated list of Route Table IDs of the target vpc"
}

variable "root_vpc_cidr" {
  description = "VPC CIDR of the root VPC"
}

variable "vpc_peering_connection_id" {
  default = "ID of the peering connection"
}