variable "upstream" {
  type    = string
  default = "4.2"
}

variable "app_name" {
  type = string
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = ""
}

variable "inbound_allowed_ip_ranges" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

variable "outbound_allowed_ip_ranges" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "extra_ports" {
  type    = list(number)
  default = []
}

variable "extra_public_ports" {
  type    = list(number)
  default = []
}

variable "extra_policies" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "token" {
  type = string
}

variable "host" {
  type    = string
  default = ""
}

variable "preset" {
  type    = string
  default = "proxy"
}

variable "proxy_pass" {
  type    = string
  default = ""
}

variable "mode" {
  type    = string
  default = "monitoring"
}

variable "libdetection" {
  type    = bool
  default = false
}

variable "global_snippet" {
  type    = string
  default = ""
}

variable "http_snippet" {
  type    = string
  default = ""
}

variable "server_snippet" {
  type    = string
  default = ""
}

variable "post_script" {
  type    = string
  default = ""
}
