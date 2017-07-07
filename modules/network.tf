######################
# VARIABLES
######################
variable "name" {}

variable "vpc_cidr" {}
variable "aws_region" {}

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = []
}

variable "private_app_subnets" {
  description = "A list of CIDR blocks for private app subnets inside the VPC."
  default     = []
}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets inside the VPC."
  default     = []
}

variable "private_persistence_subnets" {
  description = "A list of CIDR blocks for private persistence subnets inside the VPC."
  default     = []
}

## VPC-Peering variables
# Default values assigned inorder to mark them optional
variable "peer_vpc_id" {
  default = ""
}

variable "peer_vpc_cidr" {
  default = "0.0.0.0/0"
}

variable "peer_private_app_route_table_ids" {
  default = " "
}

variable "peer_owner_id" {
  description = "AWS Account ID of the owner of the peer VPC"
  default     = " "
}

## Bastion Host variables
# Default values assigned inorder to mark them optional
variable "config_bucket_name" {
  description = "Name of S3 Bucket which has config and keys to be accessed by the bastion host"
}

variable "config_bucket_arn" {
  description = "ARN of S3 Bucket which has config and keys to be accessed by the bastion host"
}

variable "bastion_host_keypair" {
  description = "Keypair name for the bastion-host instance"
  default     = "bastion-host"
}

variable "bastion_host_ami_id" {
  description = "AMI ID from which the bastian host instance will be created."
  default     = ""
}

######################
# MODULES
######################
module "vpc" {
  source = "./vpc"

  name     = "${var.name}-vpc"
  vpc_cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public-subnet"

  name           = "${var.name}-public"
  vpc_id         = "${module.vpc.vpc_id}"
  public_subnets = "${var.public_subnets}"
  azs            = "${var.azs}"
}

module "nat" {
  source = "./nat"

  name              = "${var.name}-nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

module "private_app_subnet" {
  source = "./private-app-subnet"

  name                = "${var.name}-private-app"
  vpc_id              = "${module.vpc.vpc_id}"
  private_app_subnets = "${var.private_app_subnets}"
  azs                 = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

module "private_persistence_subnet" {
  source = "./private-persistence-subnet"

  name                        = "${var.name}-private-persistence"
  vpc_id                      = "${module.vpc.vpc_id}"
  private_persistence_subnets = "${var.private_persistence_subnets}"
  azs                         = "${var.azs}"
}

module "network_acl" {
  source = "./network-acl"

  name                   = "${var.name}-acl"
  vpc_id                 = "${module.vpc.vpc_id}"
  public_subnet_ids      = "${module.public_subnet.subnet_ids}"
  private_app_subnet_ids = "${module.private_app_subnet.subnet_ids}"
}

##### VPC-PEERING
module "vpc-peering" {
  source = "./vpc-peering"
  name   = "${var.name}-vpc-peering"

  root_vpc_id          = "${module.vpc.vpc_id}"
  root_vpc_cidr        = "${module.vpc.vpc_cidr}"
  root_route_table_ids = "${module.private_app_subnet.route_table_ids}"

  # workaround: using number of availability_zones for the number of routes to be added in the route table
  # https://github.com/hashicorp/terraform/issues/3888
  root_route_table_ids_count = "${length(var.azs)}"

  peer_route_table_ids = "${var.peer_private_app_route_table_ids}"

  # workaround: using number of availability_zones for the number of routes to be added in the route table
  # https://github.com/hashicorp/terraform/issues/3888
  peer_route_table_ids_count = "${length(var.azs)}"

  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  peer_vpc_cidr = "${var.peer_vpc_cidr}"
}

module "bastion-host" {
  name                        = "${var.name}-bastion-host"
  source                      = "./bastion"
  instance_type               = "t2.nano"
  keypair                     = "${var.bastion_host_keypair}"
  ami                         = "${var.bastion_host_ami_id}"
  region                      = "${var.aws_region}"
  s3_bucket_uri               = "s3://${var.config_bucket_name}/keypairs"
  s3_bucket_arn               = "${var.config_bucket_arn}"
  vpc_id                      = "${module.vpc.vpc_id}"
  subnet_ids                  = "${module.public_subnet.subnet_ids}"
  keys_update_frequency       = "5,20,35,50 * * * *"
  additional_user_data_script = "date"
}

######################
# OUTPUTS
######################
# VPC
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}

# Subnets
output "public_subnet_ids" {
  value = "${module.public_subnet.subnet_ids}"
}

output "private_app_subnet_ids" {
  value = "${module.private_app_subnet.subnet_ids}"
}

output "private_persistence_subnet_ids" {
  value = "${module.private_persistence_subnet.subnet_ids}"
}

# Route Tables
output "private_app_route_table_ids" {
  value = "${module.private_app_subnet.route_table_ids}"
}

output "public_route_table_ids" {
  value = "${module.public_subnet.route_table_ids}"
}

# NAT
output "nat_gateway_ids" {
  value = "${module.nat.nat_gateway_ids}"
}

output "nat_public_ip" {
  value = "${module.nat.public_ip}"
}
