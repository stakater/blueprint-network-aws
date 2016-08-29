variable "name" { default = "persistance" }
variable "vpc_id" { }

variable "private_persistance_subnets" {
  description = "A list of CIDR blocks for private persistance subnets inside the VPC."
  default=[]
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default=[]
}