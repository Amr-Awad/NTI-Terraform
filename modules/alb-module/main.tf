# 2 Application load balancer  one fro rerouting requests to public instances and other for rerouting requests to private instances that is coming from public instances

resource "aws_lb" "lb" {
  name               = var.alb-name
  internal           = var.is-internal
  load_balancer_type = var.alb-type
  security_groups    = [var.alb-sg-id]
  subnets            = var.subnet-ids
}

# 2 Target groups one for public instances and other for private instances
resource "aws_lb_target_group" "target_group" {
  name     = var.target-group-name
  port     = var.lb-listener-port
  protocol = var.lb-listener-protocol
  vpc_id   = var.vpc-id
}

# 2 Listeners one for public instances and other for private instances
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.lb-listener-port
  protocol          = var.lb-listener-protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

locals {
  instance_map = { for idx, instance_id in var.instance-ids : idx => instance_id }
}


resource "aws_lb_target_group_attachment" "target_group_attachment" {
  for_each          = local.instance_map
  target_group_arn   = aws_lb_target_group.target_group.arn
  target_id          = each.value
  port               = 80
}

