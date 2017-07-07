variable "name" {
  default = "nat"
}

variable "public_subnet_ids" {}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}
