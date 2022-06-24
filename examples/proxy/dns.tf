data "aws_route53_zone" "default" {
  name = format("%s.", join(".", slice(local.domain_zone_parts, 1, length(local.domain_zone_parts))))
}

resource "aws_route53_record" "default" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.wallarm.lb.dns
    zone_id                = module.wallarm.lb.zone
    evaluate_target_health = true
  }
}
