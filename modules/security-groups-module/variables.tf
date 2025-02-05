variable "vpc-id" {
  description = "The id for the VPC"
  type        = string
}

variable "sg-name" {
  description = "The name of the security group"
  type        = string
}

variable "sg-description" {
  description = "The description of the security group"
  type        = string
}

variable "ssh-make" {
  description = "Make an ingress rule for SSH"
  type        = bool
}

variable "http-make" {
  description = "Make an ingress rule for HTTP"
  type        = bool
}

variable "https-make" {
  description = "Make an ingress rule for HTTPS"
  type        = bool
}