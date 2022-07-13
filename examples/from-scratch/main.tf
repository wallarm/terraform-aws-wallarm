provider "aws" {
  region = var.region
}

data "aws_availability_zones" "example" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

locals {
  azs_count_to_use = length(data.aws_availability_zones.example.names) > 3 ? 3 : length(data.aws_availability_zones.example.names)
  azs = slice(sort(data.aws_availability_zones.example.names), 0, local.azs_count_to_use)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "example"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  public_subnets  = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]

  enable_nat_gateway = true
}

locals {
  vpc_id          = module.vpc.vpc_id
  public_subnets  = sort(module.vpc.public_subnets)
  private_subnets = sort(module.vpc.private_subnets)
}

output "vpc" {
  value = {
    azs             = local.azs
    vpc_id          = local.vpc_id
    public_subnets  = local.public_subnets
    private_subnets = local.private_subnets
  }
  description = "Outputs of the AWS VPC module."
}

module "wallarm" {
  source = "wallarm/wallarm/aws"

  app_name = "wallarm"

  preset     = "proxy"
  mode       = "block"
  proxy_pass = "https://httpbin.org"

  vpc_id        = local.vpc_id
  instance_type = "t3.medium"

  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  autoscaling_enabled    = true
  autoscaling_cpu_target = "65.0"

  lb_subnet_ids       = local.public_subnets
  instance_subnet_ids = local.private_subnets

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
  description = "Outputs of the Wallarm AWS module."
}
