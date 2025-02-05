# Generate SSH Key Pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "ec2.pem"
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2Key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# VPC Configuration
resource "aws_vpc" "block_one" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.block_one.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "main_public"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.block_one.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "main_private"
  }
}

# Security Groups
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.block_one.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow internal traffic"
  vpc_id      = aws_vpc.block_one.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.block_one.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.block_one.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "private_ec2" {
  ami           = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_sg.id]  # Security group assigned here
  key_name      = aws_key_pair.ec2_key_pair.key_name
  tags = {
    Name = "private_ec2"
  }
}

resource "aws_instance" "public_ec2" {
  ami           = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.ec2_key_pair.key_name
  tags = {
    Name = "public_ec2"
  }
}

# Networking Components
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.block_one.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.block_one.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.block_one.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Network Interface Configuration (FIXED)
resource "aws_network_interface" "public_eni" {
  subnet_id   = aws_subnet.public_subnet.id
  tags = {
    Name = "public_eni"
  }
  depends_on = [aws_instance.public_ec2]
}

resource "aws_network_interface_attachment" "attach_public_eni" {
  instance_id          = aws_instance.public_ec2.id
  network_interface_id = aws_network_interface.public_eni.id
  device_index         = 1
}

resource "aws_network_interface_sg_attachment" "eni_sg_attach" {
  security_group_id    = aws_security_group.public_sg.id
  network_interface_id = aws_network_interface.public_eni.id
}

resource "aws_eip" "public_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_associate" {
  network_interface_id = aws_network_interface.public_eni.id
  allocation_id        = aws_eip.public_eip.id
}

# Provisioning Configuration
resource "null_resource" "setup_apache_via_public" {
  provisioner "file" {
    source      = "ec2.pem"
    destination = "/home/ec2-user/ec2.pem"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.my_key.private_key_pem
      host        = aws_eip.public_eip.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/ec2.pem",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/ec2.pem ec2-user@${aws_instance.private_ec2.private_ip} 'sudo yum update -y'",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/ec2.pem ec2-user@${aws_instance.private_ec2.private_ip} 'sudo yum install -y httpd'",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/ec2.pem ec2-user@${aws_instance.private_ec2.private_ip} 'sudo systemctl enable httpd'",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/ec2.pem ec2-user@${aws_instance.private_ec2.private_ip} 'sudo systemctl start httpd'"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.my_key.private_key_pem
      host        = aws_eip.public_eip.public_ip
    }
  }
  depends_on = [
    aws_instance.public_ec2,
    aws_eip_association.eip_associate,
    aws_instance.private_ec2,  # Ensure private EC2 is fully initialized

  ]
}