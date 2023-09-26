module "template" {
  source = "./modules/template"

  upstream = var.upstream

  app_name = local.app_name

  ami_id        = var.ami_id
  vpc_id        = var.vpc_id
  instance_type = var.instance_type

  key_name = var.key_name

  inbound_allowed_ip_ranges  = var.inbound_allowed_ip_ranges
  outbound_allowed_ip_ranges = var.outbound_allowed_ip_ranges

  # Cloud-init
  token        = var.token
  host         = var.host
  preset       = var.preset
  proxy_pass   = var.proxy_pass
  mode         = var.mode
  libdetection = var.libdetection

  # Configuration snippets
  global_snippet = var.global_snippet
  http_snippet   = var.http_snippet
  server_snippet = var.server_snippet

  # Extras
  extra_ports        = var.extra_ports
  extra_public_ports = var.extra_public_ports
  extra_policies     = var.extra_policies

  post_script = var.post_script

  tags = var.tags
}

module "lb" {
  source = "./modules/lb"

  count = (var.custom_target_group == "") ? 1 : 0

  app_name = local.app_name

  vpc_id = var.vpc_id

  lb_enabled = var.lb_enabled
  subnet_ids = var.lb_subnet_ids
  internal   = var.lb_internal

  logs_enabled   = var.lb_logs_enabled
  logs_s3_bucket = var.lb_logs_s3_bucket
  logs_prefix    = var.lb_logs_prefix

  source_ranges = var.source_ranges

  preset = var.preset

  lb_ssl_enabled      = var.lb_ssl_enabled
  ssl_policy          = var.lb_ssl_policy
  certificate_arn     = var.lb_certificate_arn
  https_redirect_code = var.https_redirect_code

  deletion_protection = var.lb_deletion_protection

  tags = var.tags
}

module "asg" {
  source = "./modules/asg"

  count = var.asg_enabled ? 1 : 0

  app_name = local.app_name

  subnet_ids = var.instance_subnet_ids
  tg_id      = var.preset != "custom" ? module.lb[0].tg_id : var.custom_target_group

  # Template
  template_id      = module.template.template_id
  template_version = module.template.template_version

  # Scaling
  max_size               = var.max_size
  min_size               = var.min_size
  desired_capacity       = var.desired_capacity
  autoscaling_enabled    = var.autoscaling_enabled
  autoscaling_cpu_target = var.autoscaling_cpu_target

  tags = var.tags
}
