variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "preset" {
  type    = string
  default = "proxy"
}

variable "lb_enabled" {
  type    = bool
  default = true
}

variable "internal" {
  type    = bool
  default = false
}

variable "lb_ssl_enabled" {
  type    = bool
  default = false
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "source_ranges" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "https_redirect_code" {
  type    = number
  default = 0
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "logs_prefix" {
  type    = string
  default = ""
}

variable "logs_s3_bucket" {
  type    = string
  default = ""
}

variable "logs_enabled" {
  type    = bool
  default = false
}

variable "xff_header_processing_mode" {
  type    = string
  default = null
}
