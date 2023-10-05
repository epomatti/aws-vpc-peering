output "instance_id" {
  value = aws_instance.windows.id
}

output "public_dns" {
  value = aws_instance.windows.public_dns
}
