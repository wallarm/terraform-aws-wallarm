resource "aws_security_group" "default" {
  count = var.lb_enabled ? 1 : 0

  name = format("%s-lb", var.app_name)

  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.preset == "proxy" ? [true] : [])
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.source_ranges
    }
  }

  dynamic "ingress" {
    for_each = toset((var.preset == "proxy" && var.certificate_arn != "") ? [true] : [])
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.source_ranges
    }
  }

  dynamic "ingress" {
    for_each = toset(var.preset == "mirror" ? [true] : [])
    content {
      from_port   = 8445
      to_port     = 8445
      protocol    = "tcp"
      cidr_blocks = var.source_ranges
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
