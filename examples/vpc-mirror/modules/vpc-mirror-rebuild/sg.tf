resource "aws_security_group" "default" {
  name_prefix = local.app_name

  vpc_id = var.vpc_id

  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"
    cidr_blocks = [
      "10.0.0.0/8",
      "192.168.0.0/16",
      "172.16.0.0/12",
    ]
  }

  ingress {
    from_port = 9445
    to_port   = 9445
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "192.168.0.0/16",
      "172.16.0.0/12",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "192.168.0.0/16",
      "172.16.0.0/12",
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
