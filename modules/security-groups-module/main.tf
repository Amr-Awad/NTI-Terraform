# Security Groups for private subnet, public subnet, and alb
resource "aws_security_group" "sg" {
  name        = var.sg-name
  description = var.sg-description
  vpc_id      = var.vpc-id

  #if variable ssh-make true then make ingress rule for ssh
  dynamic "ingress" {
    for_each = var.ssh-make == true ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  dynamic ingress {
    for_each = var.http-make == true ? [1] : []
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic ingress {
    for_each = var.https-make == true ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}