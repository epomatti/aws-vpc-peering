output "rds_address" {
  value = module.rds_postgresql.address
}

output "bastion_public_dn" {
  value = module.windows_bastion.public_dns
}
