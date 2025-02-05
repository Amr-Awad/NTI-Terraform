# This file contains the code to create a VPC, 2 public subnets, 2 private subnets, an internet gateway, and 2 nat gateway for each private subnet.

#VPC
resource "aws_vpc" "block_one" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = var.vpc-name
  }
}

#Subnets
resource "aws_subnet" "public_subnet" {
  for_each = { for index, cidr_block in var.public_subnet_cidrs : index => cidr_block }

  vpc_id            = aws_vpc.block_one.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key % length(var.azs))
  tags = {
    Name = "public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = { for index, cidr_block in var.private_subnet_cidrs : index => cidr_block }

  vpc_id            = aws_vpc.block_one.id
  cidr_block        = each.value
  availability_zone = element(var.azs, each.key % length(var.azs))
  tags = {
    Name = "private-subnet-${each.key}"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.block_one.id
}

#Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.block_one.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
}
}

#Route Table Association
resource "aws_route_table_association" "public_subnet" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

#NAT Gateway
resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.private_subnet
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = { for index, public_subnet in aws_subnet.public_subnet : index => public_subnet }
    allocation_id = aws_eip.nat_eip[each.key].id
    subnet_id     = each.value.id
}

#Route Table
resource "aws_route_table" "private_route_table" {
  for_each = aws_nat_gateway.nat_gateway

  vpc_id = aws_vpc.block_one.id

  dynamic "route" {
    for_each = [each.value]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value.id
    }
  }

  tags = {
    Name = "Private Route Table ${each.key}"
  }
}



#Route Table Association
resource "aws_route_table_association" "private_subnet" {
  for_each = { for index, private_subnet in aws_subnet.private_subnet : index => private_subnet }

    subnet_id      = each.value.id
    route_table_id = aws_route_table.private_route_table[each.key].id
}
