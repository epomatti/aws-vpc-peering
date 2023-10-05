variable "solution_region" {
  type = string
}

variable "bastion_region" {
  type = string
}

variable "rds_instance_class" {
  type = string
}

variable "rds_multi_az" {
  type = bool
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "jumpserver_allow_ssh" {
  type = list(string)
}

variable "windows_instance_type" {
  type = string
}

variable "solution_vpc_cidr_prefix" {
  type = string
}

variable "bastion_vpc_cidr_prefix" {
  type = string
}
