variable "app_name" {
  type        = string
  description = "Prefix name of the components."
}

variable "direction_egress_enable" {
  type    = bool
  default = false
}

variable "direction_ingress_enable" {
  type    = bool
  default = true
}

variable "network_interface_ids" {
  type = list(string)
  validation {
    condition     = length(var.network_interface_ids) == 0 || alltrue([for i in var.network_interface_ids : length(i) > 4 && substr(i, 0, 4) == "eni-"])
    error_message = "The network_interface_ids must be a list of valid ids of ENI, starting with \"eni-\"."
  }
  description = "The ENIs for mirroring."
}

variable "target_nlb_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:.+:\\d+:loadbalancer/.+", var.target_nlb_arn))
    error_message = "The target_nlb_arn must be a valid network load balancer ARN by the regexp: \"arn:aws:elasticloadbalancing:.+:\\d+:loadbalancer/.+\"."
  }
  description = "Endpoint for mirrored packets."
}

variable "session_id" {
  type        = number
  default     = 1
  description = "Uniq number of sessions. For multiple ENIs this variables is a start of numbers sequence."
}

variable "vxlan_id" {
  type        = number
  default     = 1377
  description = "VXLAN VNI, in VXLAN header."
}
