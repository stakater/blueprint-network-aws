variable "name" {
  default = "private-app"
}

variable "vpc_id" {}
variable "nat_gateway_ids" {}

variable "private_app_subnets" {
  description = "A list of CIDR blocks for private app subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}
