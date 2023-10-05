terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.requester, aws.accepter]
    }
  }
}


data "aws_caller_identity" "peer" {}

locals {
  account_id = data.aws_caller_identity.peer.account_id
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  provider = aws.requester

  vpc_id        = var.bastion_requester_vpc_id
  peer_vpc_id   = var.solution_accepter_vpc_id
  peer_owner_id = local.account_id

  # Auto-accept must be false for x-region, and must use accepter
  auto_accept = false
  peer_region = var.solution_accepter_vpc_region

  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  provider = aws.requester

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}
