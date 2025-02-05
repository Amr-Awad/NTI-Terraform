# output the pubic ssh key
output "ssh-key" {
  description = "The SSH key pair"
  value       = aws_key_pair.ec2_key_pair.key_name
}

#output the private key
output "private_key" {
  description = "The private key"
  value = tls_private_key.my_key.private_key_pem
}