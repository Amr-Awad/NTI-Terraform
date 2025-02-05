variable "public-instance-ips" {
  description = "The public ip for the public instances"
  type        = list(string)
}

variable "private-instance-ips" {
  description = "The private ips for the private instances"
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

#variables for the ec2 instance ids
variable "public-ec2-instance-ids" {
  description = "The public ids of the ec2 instances"
  type        = list(string)
}

variable "private-ec2-instance-ids" {
  description = "The private ids of the ec2 instances"
  type        = list(string)
}

