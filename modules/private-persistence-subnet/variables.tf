variable "name" {
  default = "persistence"
}

variable "vpc_id" {}

variable "private_persistence_subnets" {
  description = "A list of CIDR blocks for private persistence subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}
