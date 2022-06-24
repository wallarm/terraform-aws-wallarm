resource "aws_security_group" "default" {
  name = format("%s-instances", var.app_name)

  vpc_id = var.vpc_id

  ingress { # healthcheck and metrics
    from_port   = 9445
    to_port     = 9445
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowed_ip_ranges
  }

  ingress { # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.inbound_allowed_ip_ranges
  }

  dynamic "ingress" {
    for_each = toset(var.preset == "proxy" ? [true] : [])
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.inbound_allowed_ip_ranges
    }
  }

  dynamic "ingress" {
    for_each = toset(var.preset == "mirror" ? [true] : [])
    content {
      from_port   = 8445
      to_port     = 8445
      protocol    = "tcp"
      cidr_blocks = var.inbound_allowed_ip_ranges
    }
  }

  dynamic "ingress" {
    for_each = toset(var.extra_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.inbound_allowed_ip_ranges
    }
  }

  dynamic "ingress" {
    for_each = toset(var.extra_public_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.outbound_allowed_ip_ranges
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
