output "instance-id" {
  description = "The IDs of the instance"
  value = aws_instance.ec2-instance.id
}


#public ip addresses of ec2 instance 
output "instance-ip" {
  description = "The public or private IP address of the instance based on the is_public variable"
  value = var.is-public ? aws_instance.ec2-instance.public_ip : aws_instance.ec2-instance.private_ip
}

output "is-public" {
  description = "Boolean value to determine if the instance is public or private"
  value = var.is-public
}

output "instance_ids" {
  description = "The IDs of the created instances"
  value       = [aws_instance.ec2-instance.id]
}

#conditional output for the public ip address or private ip address
output "instance_ips" {
  description = "The public or private IP addresses of the instances"
  value = var.is-public ? [aws_instance.ec2-instance.public_ip] : [aws_instance.ec2-instance.private_ip]
  
}