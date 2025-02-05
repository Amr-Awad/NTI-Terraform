output "vpc-id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.block_one.id
}
output "subnets" {
  description = "The IDs of the created subnets"
  value       = concat(
    [for subnet in aws_subnet.public_subnet : subnet.id],
    [for subnet in aws_subnet.private_subnet : subnet.id]
  )
}


#output cidr block
output "vpc-cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.block_one.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "private_subnet_validation" {
  value = length(var.private_subnet_cidrs) % length(var.azs) == 0 && length(var.private_subnet_cidrs) == length(var.public_subnet_cidrs) ? "Valid private subnet configuration" : "Invalid private subnet configuration"
}

output "public_subnet_validation" {
  value = length(var.public_subnet_cidrs) % length(var.azs) == 0 && length(var.private_subnet_cidrs) == length(var.public_subnet_cidrs) ? "Valid private subnet configuration" : "Invalid private subnet configuration"
}
