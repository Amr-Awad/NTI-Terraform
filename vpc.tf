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
  cidr_block = var.cidr[0]
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.block_one.id
  cidr_block        = var.cidr[1]
  availability_zone = var.az[0]
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.block_one.id
  cidr_block        = var.cidr[2]
  availability_zone = var.az[0]
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.block_one.id
  cidr_block        = var.cidr[3]
  availability_zone = var.az[1]
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.block_one.id
  cidr_block        = var.cidr[4]
  availability_zone = var.az[1]
  tags = {
    Name = "private-subnet-2"
  }
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.block_one.id

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
  name        = "private-sg"
  description = "Allow traffic from ALB and SSH from VPC"
  vpc_id      = aws_vpc.block_one.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.block_one.id
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.block_one.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateways (One per AZ for redundancy)
resource "aws_eip" "eip_1" {
  domain = "vpc"
}

resource "aws_eip" "eip_2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}

# Private Route Tables
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.block_one.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.block_one.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }
}

resource "aws_route_table_association" "private_rt_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_rt_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

# Application Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_tg.arn
  }
}

resource "aws_lb_target_group" "my_lb_tg" {
  name     = "my-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.block_one.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Auto Scaling Group with Launch Template
resource "aws_launch_template" "my_lt" {
  name          = "my-launch-template"
  image_id      = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<h1>Hello World from $(hostname -I)</h1>" > /var/www/html/index.html
    EOF
  )
}

resource "aws_autoscaling_group" "my_asg" {
  name                = "my-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  target_group_arns   = [aws_lb_target_group.my_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.my_lt.id
    version = "$Latest"
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "LowCPUUsage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }
}