variable "app_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "tg_id" {
  type = string
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "autoscaling_enabled" {
  type    = bool
  default = false
}

variable "autoscaling_cpu_target" {
  type    = string
  default = "70.0"
}

variable "template_id" {
  type = string
}

variable "template_version" {
  type = string
}
