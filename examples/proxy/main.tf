provider "aws" {
  region = var.region
}

module "wallarm" {
  source = "../.." # TODO

  app_name = "wallarm"

  ### "proxy_pass" is required when "preset" is "proxy"
  ###
  preset     = "proxy"
  proxy_pass = "https://httpbin.org"

  ### You can configure SSL offloading with AWS ACM. So, then
  ### it is recommended to make auto https forwarding. For production
  ### use ALB's embedded redirect rule, with "https_redirect_code"
  ### option of the module.
  ###
  lb_ssl_enabled      = true
  lb_certificate_arn  = aws_acm_certificate.default.arn
  https_redirect_code = 302

  vpc_id        = var.vpc_id
  instance_type = "t3.medium"

  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  autoscaling_enabled    = true
  autoscaling_cpu_target = "65.0"

  lb_subnet_ids       = var.public_subnets
  instance_subnet_ids = var.private_subnets

  token = var.token

  lb_deletion_protection = false

  depends_on = [
    aws_acm_certificate_validation.default,
  ]
}

output "suboutputs" {
  value = {
    asg      = module.wallarm.asg
    lb       = module.wallarm.lb
    tg       = module.wallarm.tg
    template = module.wallarm.template
    role     = module.wallarm.role
    other    = module.wallarm.other
  }
  description = "Outputs of the module."
}
