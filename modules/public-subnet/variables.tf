variable "name" {
  default = "public"
}

variable "vpc_id" {}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets inside the VPC."
  default     = []
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}
