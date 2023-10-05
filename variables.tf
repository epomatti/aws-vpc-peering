### VPC Peering ###
variable "solution_region" {
  type = string
}

variable "bastion_region" {
  type = string
}

variable "solution_vpc_cidr_prefix" {
  type = string
}

variable "bastion_vpc_cidr_prefix" {
  type = string
}

### RDS ###
variable "rds_instance_class" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

### Bastion ###
variable "windows_instance_type" {
  type = string
}

variable "windows_ami" {
  type = string
}
