provider "aws" {
  region = var.region
}

module "wallarm" {
  source = "../.." # TODO

  app_name = "wallarm"

  preset = "mirror"

  vpc_id        = var.vpc_id
  instance_type = "t3.medium"

  lb_internal         = true
  lb_subnet_ids       = var.private_subnets
  instance_subnet_ids = var.private_subnets

  token = var.token

  lb_deletion_protection = false
}

output "mirror_endpoint" {
  value = module.wallarm.other.mirror_endpoint
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
