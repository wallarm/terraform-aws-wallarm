resource "aws_lb" "default" {
  name = local.app_name

  load_balancer_type = "network"
  internal           = true

  subnets = var.subnet_ids

  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "default" {
  name = local.app_name

  vpc_id = var.vpc_id

  port     = 4789
  protocol = "UDP"

  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    interval            = 10
    path                = "/-/healthcheck"
    port                = 9445
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn

  port     = 4789
  protocol = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}
