#output of security groups
output "sg-id" {
  description = "The ID of the public security group"
  value       = aws_security_group.sg.id
}

