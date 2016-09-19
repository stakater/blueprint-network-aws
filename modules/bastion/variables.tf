variable "region" { }
variable "vpc_id" { }
variable "ami" { }

variable "name" {
  default = "bastion"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "iam_instance_profile" {
}

variable "s3_bucket_name" {
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

variable "eip" {
  default = ""
}