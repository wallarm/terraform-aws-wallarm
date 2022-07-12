resource "aws_vpc_endpoint" "demo" {
  count = var.apigw_private ? 1 : 0

  vpc_id            = var.vpc_id

  vpc_endpoint_type = "Interface"
  service_name      = format(
    "com.amazonaws.%s.execute-api",
    var.region,
  )

  subnet_ids         = var.private_subnets
  security_group_ids = [
    aws_security_group.demo.id,
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "demo" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "192.168.0.0/16",
      "172.16.0.0/12",
      "10.0.0.0/10",
    ]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "192.168.0.0/16",
      "172.16.0.0/12",
      "10.0.0.0/10",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
