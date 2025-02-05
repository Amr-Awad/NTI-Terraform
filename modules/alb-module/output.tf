#output for 2 alb ids and the public and private dns names

output "alb-id" {
  description = "The IDs of the ALBs"
  value = aws_lb.lb.id
}

# output the public dns if found else output the private dns based on is_public variable
output "alb-dns" {
  description = "The DNS of the ALBs"
  value = aws_lb.lb.dns_name
}

