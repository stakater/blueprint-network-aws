variable "name" { }
variable "target_vpc_id" { }
variable "rood_vpc_id" { }

variable "target_owner_id" {
  description = "AWS account ID of the account through which the target vpc was created"
}

variable "root_route_table_ids" {
  description = "Comma-separated list of Route Table IDs of the root vpc"
}

variable "target_vpc_cidr" {
  description = "VPC CIDR of the target VPC"
}