variable "name" { default = "acl" }
variable "vpc_id" { }

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets inside the VPC."
  default=[]
}

variable "private_app_subnets" {
  description = "A list of CIDR blocks for private app subnets inside the VPC."
  default=[]
}