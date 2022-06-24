resource "aws_lb_target_group" "proxy" {
  count = var.preset == "proxy" ? 1 : 0

  name = var.app_name

  vpc_id = var.vpc_id

  port     = 80
  protocol = "HTTP"

  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    interval            = 5
    timeout             = 3
    path                = "/-/healthcheck"
    port                = 9445
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_target_group" "mirror" {
  count = var.preset == "mirror" ? 1 : 0

  name = var.app_name

  vpc_id = var.vpc_id

  port     = 8445
  protocol = "HTTP"

  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    interval            = 5
    timeout             = 3
    path                = "/-/healthcheck"
    port                = 9445
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = var.tags
}
