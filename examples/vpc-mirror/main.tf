provider "aws" {
  region = var.region
}

module "vpc-mirror" {
  source = "./modules/vpc-mirror-sessions"

  app_name = "vpc-mirror"

  session_id = 8 # random

  direction_egress_enable  = false
  direction_ingress_enable = true

  vxlan_id = 1377

  ### You are welcome to review "interfaces.tf" file. In this
  ### example we catch anterfaces by autoscaling group.
  ### So, you can see additional options in "enis" folder.
  ###
  network_interface_ids = values(data.aws_instance.example)[*].network_interface_id

  target_nlb_arn = module.vxlan-rebuild.nlb_arn
}

module "vxlan-rebuild" {
  source = "./modules/vpc-mirror-rebuild"

  app_name = "vxlan-rebuild"

  vpc_id        = var.vpc_id
  subnet_ids    = var.private_subnets
  instance_type = "t3.small"

  vxlan_id = 1377

  mirror_endpoint = module.wallarm.other.mirror_endpoint

  ### Enables output of catched requests into service log.
  ###   `journalctl -xefu gereplay.service`
  ###
  debug = true
}

module "wallarm" {
  source = "../.." # TODO

  app_name = "wallarm"

  preset = "mirror"

  vpc_id        = var.vpc_id
  instance_type = "t3.small"

  lb_internal         = true
  lb_subnet_ids       = var.private_subnets
  instance_subnet_ids = var.private_subnets

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
