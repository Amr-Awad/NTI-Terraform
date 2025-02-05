#create data source for the amazon linux ami
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon's official AWS AMI account ID
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's AWS Account ID for official Ubuntu images
}

resource "aws_instance" "ec2-instance" {
  # instance ami based on the linux-type
  ami           = var.linux-type == "amazon-linux" ? data.aws_ami.amazon_linux.id : data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  subnet_id     = var.subnet-id
  key_name      = var.ssh-key
  associate_public_ip_address = var.is-public
  vpc_security_group_ids = [var.sg-id]
  tags = {
    Name = var.is-public == true ? "ec2-instance-public" : "ec2-instance-private"
  }
}