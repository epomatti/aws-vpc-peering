output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}
