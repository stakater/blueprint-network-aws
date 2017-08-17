variable "name" {
  default = "spare"
}

variable "vpc_id" {}

variable "spare_subnets" {
  description = "A list of CIDR blocks for spare subnets inside the VPC."
  type        = "list"
}

variable "azs" {
  description = "A list of Availability zones in the region"
  type        = "list"
}
