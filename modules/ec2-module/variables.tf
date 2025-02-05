
variable "subnet-id" {
  description = "The ids for the subnets"
  type        = string
}

variable "sg-id" {
  description = "The id for the public security group"
  type        = string
}

variable "instance-type" {
  description = "The type of instance to launch"
  type        = string
}

variable "linux-type" {
  description = "The AMI to use for the instance"
  type        = string
  #condition to check if the linux-type is either amazon-linux-2 or ubuntu
  validation {
    condition = var.linux-type == "amazon-linux" || var.linux-type == "ubuntu"
    error_message = "The linux-type must be either amazon-linux-2 or ubuntu"
  }
}

variable "ssh-key" {
  description = "The name of the key pair to use"
  type        = string
}

variable "is-public" {
  description = "Boolean to determine if the instance should have a public IP"
  type        = bool
}

