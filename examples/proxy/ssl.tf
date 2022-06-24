resource "aws_acm_certificate" "default" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = []
}

locals {
  domain_zone_parts = compact(split(".", trim(var.domain_name, ".")))
}

resource "aws_route53_record" "acm" {
  for_each = {
    for item in aws_acm_certificate.default.domain_validation_options : item.domain_name => {
      name   = item.resource_record_name
      record = item.resource_record_value
      type   = item.resource_record_type
    }
  }

  allow_overwrite = true

  name = each.value.name
  records = [
    each.value.record,
  ]
  ttl     = 300
  type    = each.value.type
  zone_id = data.aws_route53_zone.default.zone_id
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.default.arn
}
