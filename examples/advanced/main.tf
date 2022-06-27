provider "aws" {
  region = var.region
}

module "wallarm" {
  source = "wallarm/wallarm/aws"

  app_name = "wallarm"

  ### "proxy_pass" is required when "preset" is "proxy"
  ###
  preset     = "proxy"
  proxy_pass = "https://httpbin.org"

  mode = "block"

  global_snippet = file(format("%s/global_snippet.conf", path.module))
  http_snippet   = file(format("%s/http_snippet.conf", path.module))
  server_snippet = file(format("%s/server_snippet.conf", path.module))

  vpc_id        = var.vpc_id
  instance_type = "t3.small"

  extra_ports = [7777]
  extra_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]

  lb_enabled          = false
  instance_subnet_ids = var.private_subnets

  token = var.token

  post_script = file(format("%s/post-cloud-init.sh", path.module))
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
