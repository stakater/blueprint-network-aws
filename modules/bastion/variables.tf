variable "region" {}
variable "vpc_id" {}
variable "ami" {}

variable "name" {
  default = "bastion-host"
}

variable "keypair" {
  default = "bastion-host"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "s3_bucket_name" {
  default = "" # Default value is a must: https://github.com/hashicorp/terraform/issues/8146
}

variable "s3_bucket_arn" {
  default = ""
}

variable "s3_bucket_uri" {
  default = ""
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "enable_hourly_cron_updates" {
  default = "false"
}

variable "keys_update_frequency" {
  default = ""
}

variable "additional_user_data_script" {
  default = ""
}

variable "security_group_ids" {
  description = "Comma seperated list of security groups to apply to the bastion."
  default     = ""
}

variable "subnet_ids" {
  description = "Comma separated list of subnet ids"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC."
  default     = true
}

variable "allow_ssh_cidrs" {
  description = "List Cidrs from where ssh is to be allowed for bastion host. Default is anywhere"
  type        = list
  default     = ["0.0.0.0/0"]
}

variable "eip" {
  default = ""
}
