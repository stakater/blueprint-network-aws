variable "name" { }
variable "target_vpc_id" { }
variable "root_vpc_id" { }

variable "target_owner_id" {
  description = "AWS account ID of the account through which the target vpc was created"
}

variable "root_route_table_ids" {
  description = "List of Route Table IDs of the root vpc"
  type = "list"
}

variable "root_route_table_ids_count" {
  description = "count for root_route_table_ids list (https://github.com/hashicorp/terraform/issues/3888)"
}

variable "target_vpc_cidr" {
  description = "VPC CIDR of the target VPC"
}