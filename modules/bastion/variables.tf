variable "workload" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet" {
  type = string
}

variable "az" {
  type = string
}

variable "allow_ssh" {
  type = list(string)
}
