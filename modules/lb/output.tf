locals {
  tg_name = compact([
    var.preset == "proxy" ? try(aws_lb_target_group.proxy[0].name, "") : "",
    var.preset == "mirror" ? try(aws_lb_target_group.mirror[0].name, "") : "",
  ])[0]

  tg_id = compact([
    var.preset == "proxy" ? try(aws_lb_target_group.proxy[0].id, "") : "",
    var.preset == "mirror" ? try(aws_lb_target_group.mirror[0].id, "") : "",
  ])[0]

  tg_arn = compact([
    var.preset == "proxy" ? try(aws_lb_target_group.proxy[0].arn, "") : "",
    var.preset == "mirror" ? try(aws_lb_target_group.mirror[0].arn, "") : "",
  ])[0]
}

output "lb_name" {
  value = try(aws_lb.default[0].name, "")
}

output "lb_arn" {
  value = try(aws_lb.default[0].arn, "")
}

output "lb_dns" {
  value = try(aws_lb.default[0].dns_name, "")
}

output "lb_zone" {
  value = try(aws_lb.default[0].zone_id, "")
}

output "tg_name" {
  value = local.tg_name
}

output "tg_id" {
  value = local.tg_id
}

output "tg_arn" {
  value = local.tg_arn
}
