variable "vpc-name" {
  description = "The name tag for the VPC"
  type        = string

  default = "block-one-vpc"
}



variable "vpc-cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "You must define at least one private subnet."
  }
}


variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) > 0
    error_message = "You must define at least one private subnet."
  }
}


variable "azs" {
  description = "List of availability zones"
  type        = list
    validation {
    condition     = length(var.azs) > 0
    error_message = "The number of private subnets must be greater than 0"
  }
  
  default = ["us-east-1a", "us-east-1b"]
}
