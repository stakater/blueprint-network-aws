######################
# VARIABLES
######################
variable "name"            { }
variable "vpc_cidr"        { }

variable "azs" {
  description = "A list of Availability zones in the region"
  default=[]
}

variable "private_app_subnets" {
  description = "A list of CIDR blocks for private app subnets inside the VPC."
  default=[]
}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets inside the VPC."
  default=[]
}

variable "private_persistance_subnets" {
  description = "A list of CIDR blocks for private persistance subnets inside the VPC."
  default=[]
}


######################
# MODULES
######################
module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  vpc_cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public-subnet"

  name   = "${var.name}-public"
  vpc_id = "${module.vpc.vpc_id}"
  public_subnets  = "${var.public_subnets}"
  azs    = "${var.azs}"
}

module "nat" {
  source = "./nat"

  name              = "${var.name}-nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_app_subnet" {
  source = "./private-app-subnet"

  name   = "${var.name}-private-app"
  vpc_id = "${module.vpc.vpc_id}"
  private_app_subnets  = "${var.private_app_subnets}"
  azs    = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

module "private_persistance_subnet" {
  source = "./private-persistance-subnet"

  name   = "${var.name}-private-persistance"
  vpc_id = "${module.vpc.vpc_id}"
  private_persistance_subnets  = "${var.private-persistance-subnet}"
  azs    = "${var.azs}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids), split(",", module.private_subnet.subnet_ids))}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags { Name = "${var.name}-all" }
}

######################
# OUTPUTS
######################
# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }

# Subnets
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_app_subnet_ids" { value = "${module.private_app_subnet.subnet_ids}" }
output "private_persistance_subnet_ids" { value = "${module.private_persistance_subnet.subnet_ids}" }

# NAT
output "nat_gateway_ids" { value = "${module.nat.nat_gateway_ids}" }