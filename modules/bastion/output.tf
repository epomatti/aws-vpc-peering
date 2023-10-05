output "instance_id" {
  value = aws_instance.jumpserver.id
}

output "public_dns" {
  value = aws_instance.jumpserver.public_dns
}
