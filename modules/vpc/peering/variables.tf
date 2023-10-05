variable "bastion_requester_vpc_id" {
  type = string
}

variable "solution_accepter_vpc_id" {
  type = string
}

variable "solution_accepter_vpc_region" {
  type = string
}

variable "bastion_requester_route_table_id" {
  type = string
}

variable "solution_accepter_route_table_id" {
  type = string
}

variable "bastion_requester_vpc_cidr_block" {
  type = string
}

variable "solution_accepter_vpc_cidr_block" {
  type = string
}
