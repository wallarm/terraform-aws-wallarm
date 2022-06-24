resource "aws_lb" "default" {
  count = var.lb_enabled ? 1 : 0

  name = var.app_name

  load_balancer_type = "application"

  internal = var.internal

  subnets = var.subnet_ids

  enable_deletion_protection = var.deletion_protection

  security_groups = [
    aws_security_group.default[0].id,
  ]

  enable_http2 = true

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  count = (var.lb_enabled && var.preset == "proxy") ? 1 : 0

  load_balancer_arn = aws_lb.default[0].arn

  port     = 80
  protocol = "HTTP"

  dynamic "default_action" {
    for_each = toset((var.certificate_arn == "" || var.https_redirect_code == 0) ? [true] : [])
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.proxy[0].arn
    }
  }

  dynamic "default_action" {
    for_each = toset((var.certificate_arn != "" && var.https_redirect_code != 0) ? [true] : [])
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = format("HTTP_%d", var.https_redirect_code)
      }
    }
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  count = (var.lb_enabled && var.preset == "proxy" && var.lb_ssl_enabled) ? 1 : 0

  load_balancer_arn = aws_lb.default[0].arn

  port     = 443
  protocol = "HTTPS"

  ssl_policy      = var.ssl_policy
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy[0].arn
  }

  tags = var.tags
}

resource "aws_lb_listener" "mirror" {
  count = (var.lb_enabled && var.preset == "mirror") ? 1 : 0

  load_balancer_arn = aws_lb.default[0].arn

  port     = 8445
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mirror[0].arn
  }

  tags = var.tags
}
