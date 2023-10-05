terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_region" "current" {}

locals {
  aws_region = data.aws_region.current.name

  azs = [
    "${local.aws_region}a",
    "${local.aws_region}b"
  ]
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_prefix}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.workload}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.workload}"
  }
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.cidr_prefix}.101.0/24"
  availability_zone       = local.azs[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-priv1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${var.cidr_prefix}.102.0/24"
  availability_zone       = local.azs[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-priv2"
  }
}

