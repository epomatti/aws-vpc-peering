terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = var.solution_region
  alias  = "solution"
}

provider "aws" {
  region = var.bastion_region
  alias  = "bastion"
}

locals {
  solution_name = "demosolution"
  bastion_name  = "demobastion"
}

module "vpc_solution" {
  source      = "./modules/vpc/solution"
  workload    = local.solution_name
  cidr_prefix = var.solution_vpc_cidr_prefix

  providers = {
    aws = aws.solution
  }
}

module "vpc_bastion" {
  source      = "./modules/vpc/bastion"
  workload    = local.bastion_name
  cidr_prefix = var.bastion_vpc_cidr_prefix

  providers = {
    aws = aws.bastion
  }
}

module "vpc_peering" {
  source                       = "./modules/vpc/peering"
  bastion_requester_vpc_id     = module.vpc_bastion.vpc_id
  solution_accepter_vpc_id     = module.vpc_solution.vpc_id
  solution_accepter_vpc_region = var.solution_region

  bastion_requester_route_table_id = module.vpc_bastion.route_table_id
  bastion_requester_vpc_cidr_block = module.vpc_bastion.cidr_block

  solution_accepter_route_table_id = module.vpc_solution.route_table_id
  solution_accepter_vpc_cidr_block = module.vpc_solution.cidr_block

  providers = {
    aws.requester = aws.bastion
    aws.accepter  = aws.solution
  }
}

module "rds_postgresql" {
  source                    = "./modules/rds"
  workload                  = local.solution_name
  vpc_id                    = module.vpc_solution.vpc_id
  subnets                   = module.vpc_solution.private_subnets
  instance_class            = var.rds_instance_class
  username                  = var.rds_username
  password                  = var.rds_password
  bastin_peering_cidr_block = module.vpc_bastion.cidr_block

  providers = {
    aws = aws.solution
  }
}

# module "jumpserver" {
#   source    = "./modules/jumpserver"
#   workload  = local.workload
#   vpc_id    = module.vpc.vpc_id
#   az        = module.vpc.azs[0]
#   subnet    = module.vpc.public_subnets[0]
#   allow_ssh = var.jumpserver_allow_ssh
# }

# module "windows" {
#   source        = "./modules/windows"
#   workload      = local.workload
#   vpc_id        = module.vpc.vpc_id
#   az            = module.vpc.azs[0]
#   subnet        = module.vpc.public_subnets[0]
#   instance_type = var.windows_instance_type
# }
