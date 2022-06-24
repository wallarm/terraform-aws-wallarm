locals {
  # https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
  transport_protocol_id = 6 # TCP

  network_interface_ids = sort(var.network_interface_ids)
}

resource "aws_ec2_traffic_mirror_filter" "default" {
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_filter_rule" "egress_default" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.default.id
  traffic_direction        = "egress"
  rule_number              = 110

  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block      = "0.0.0.0/0"

  rule_action = "reject"
}

resource "aws_ec2_traffic_mirror_filter_rule" "ingress_default" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.default.id
  traffic_direction        = "ingress"
  rule_number              = 120

  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block      = "0.0.0.0/0"

  rule_action = "reject"
}

resource "aws_ec2_traffic_mirror_filter_rule" "egress_tcp" {
  count = var.direction_egress_enable ? 1 : 0

  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.default.id
  traffic_direction        = "egress"
  rule_number              = 10

  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block      = "0.0.0.0/0"

  rule_action = "accept"

  protocol = local.transport_protocol_id
}

resource "aws_ec2_traffic_mirror_filter_rule" "ingress_tcp" {
  count = var.direction_ingress_enable ? 1 : 0

  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.default.id
  traffic_direction        = "ingress"
  rule_number              = 20

  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block      = "0.0.0.0/0"

  rule_action = "accept"

  protocol = local.transport_protocol_id
}

resource "aws_ec2_traffic_mirror_target" "default" {
  network_load_balancer_arn = var.target_nlb_arn
}

resource "aws_ec2_traffic_mirror_session" "default" {
  for_each = toset(local.network_interface_ids)

  network_interface_id = each.value

  session_number     = var.session_id + index(local.network_interface_ids, each.value)
  virtual_network_id = var.vxlan_id

  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.default.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.default.id
}
