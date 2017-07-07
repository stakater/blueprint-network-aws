variable "name" {}
variable "root_vpc_id" {}

variable "root_vpc_cidr" {
  description = "VPC CIDR of the root VPC"
}

variable "root_route_table_ids" {
  description = "List of Route Table IDs of the root vpc"
}

variable "root_route_table_ids_count" {
  description = "count for root_route_table_ids list (https://github.com/hashicorp/terraform/issues/3888)"
  default     = "1"                                                                                        # Default value is a must: https://github.com/hashicorp/terraform/issues/8146
}

variable "peer_vpc_id" {}

variable "peer_owner_id" {
  description = "AWS account ID of the account through which the peer vpc was created"
}

variable "peer_vpc_cidr" {
  description = "VPC CIDR of the peer VPC"
}

variable "peer_route_table_ids" {
  description = "Comma-separated list of Route Table IDs of the peer vpc"
}

variable "peer_route_table_ids_count" {
  description = "Count for peer_route_table_ids list (https://github.com/hashicorp/terraform/issues/3888)"
  default     = "1"                                                                                        # Default value is a must: https://github.com/hashicorp/terraform/issues/8146
}
