locals {
  app_name = var.app_name_no_template ? var.app_name : format("%s-%s", var.app_name, random_string.random[0].result)
}

resource "random_string" "random" {
  count = var.app_name_no_template ? 0 : 1

  length = 5

  lower   = true
  upper   = false
  numeric = false
  special = false
}
