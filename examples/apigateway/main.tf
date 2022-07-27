provider "aws" {
  region = var.region
}

module "wallarm" {
  source = "wallarm/wallarm/aws"

  app_name = "wallarm"

  preset     = "proxy"
  proxy_pass = format(
    "https://%s.execute-api.%s.amazonaws.com",
    aws_api_gateway_rest_api.demo.id,
    var.region,
  )

  vpc_id        = var.vpc_id
  instance_type = "t3.medium"

  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  autoscaling_enabled    = true
  autoscaling_cpu_target = "65.0"

  lb_subnet_ids       = var.public_subnets
  instance_subnet_ids = var.private_subnets

  host  = var.host
  token = var.token

  lb_deletion_protection = false
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
