variable "vpc-id" {
  description = "The id for the VPC"
  type        = string
}

variable "alb-name" {
  description = "The name of the ALB"
  type        = string
}

variable "is-internal" {
  description = "Boolean to determine if the ALB should be internet facing"
  type        = bool
}

variable "alb-type" {
  description = "The type of ALB to launch"
  type        = string
  #condition to check if the alb-type is either application or network
  validation {
    condition = var.alb-type == "application" || var.alb-type == "network"
    error_message = "The alb-type must be either application or network"
  }
}



variable "subnet-ids" {
  description = "The ids for the private subnets"
  type        = list(string)
}

variable "alb-sg-id" {
  description = "The id for the security group"
  type        = string
}

variable "instance-ids" {
  description = "The ids for the public instances"
  type        = list(string)
}

variable "target-group-name" {
  description = "The name of the target group"
  type        = string
}

variable "lb-listener-port" {
    description = "The port that the listener will listen to"
    type        = string
}

variable "lb-listener-protocol" {
    description = "The protocol that will use"
    type        = string
}

