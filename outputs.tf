output "asg" {
  value = {
    name = try(module.asg[0].asg_name, "")
    id   = try(module.asg[0].asg_id, "")
    arn  = try(module.asg[0].asg_arn, "")
  }
  description = "AWS Auto Scaling Group IDs."
}

output "lb" {
  value = {
    name = try(module.lb[0].lb_name, "")
    arn  = try(module.lb[0].lb_arn, "")
    dns  = try(module.lb[0].lb_dns, "")
    zone = try(module.lb[0].lb_zone, "")
  }
  description = "AWS ALB IDs and DNS name."
}

output "tg" {
  value = {
    name = try(module.lb[0].tg_name, "")
    id   = try(module.lb[0].tg_id, "")
    arn  = try(module.lb[0].tg_arn, "")
  }
  description = "Created Target Group IDs."
}

output "template" {
  value = {
    name    = module.template.template_name
    id      = module.template.template_id
    version = module.template.template_version
  }
  description = "AWS EC2 Template IDs."
}

output "role" {
  value = {
    name = module.template.role_name
    arn  = module.template.role_arn
  }
  description = "AWS IAM Role IDs. Empty string means AWS IAM Role do not exist."
}

output "other" {
  value = {
    ami_id          = module.template.ami_id
    mirror_endpoint = var.preset == "mirror" ? try(format("http://%s:8445", module.lb[0].lb_dns), "") : ""
  }
  description = "Other output variables."
}
