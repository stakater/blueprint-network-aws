variable "target_route_table_ids" {
  description = "Comma-separated list of Route Table IDs of the target vpc"
}

variable "target_route_table_ids_count" {
  description = "Count for target_route_table_ids list (https://github.com/hashicorp/terraform/issues/3888)"
  default = "1" # Default value is a must: https://github.com/hashicorp/terraform/issues/8146
}

variable "root_vpc_cidr" {
  description = "VPC CIDR of the root VPC"
}

variable "vpc_peering_connection_id" {
  default = "ID of the peering connection"
}