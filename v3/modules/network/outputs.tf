output "subnet_id" {
  value = aws_subnet.honeynet_subnet.id
}
output "security_group_id" {
  value = aws_security_group.honeypot_sg.id
}