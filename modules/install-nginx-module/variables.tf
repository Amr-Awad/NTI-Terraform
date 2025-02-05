variable "public-instance-ips" {
  description = "The public ips for the public instances"
  type        = list(string)
}

variable "ec2-private-key" {
  description = "The private key for the ec2 instances"
  type        = string
}

variable "private-lb-dns" {
  description = "The private dns of the private load balancers"
  type        = string
}

#variables for the load balancer ids
variable "lb-ids" {
  description = "The ids of the private load balancers"
  type        = list(string)
}

#variables for the ec2 instance ids
variable "public-ec2-instance-ids" {
  description = "The public ids of the ec2 instances"
  type        = list(string)
}

variable "private-ec2-instance-ids" {
  description = "The private ids of the ec2 instances"
  type        = list(string)
}

