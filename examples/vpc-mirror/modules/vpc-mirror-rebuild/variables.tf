variable "app_name" {
  type        = string
  description = "Prefix name of the components."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC identificator."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnets for putting instances and NLB in."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "Optional. Name of the key pair. You are welcome to use AWS SSM too."
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "VXLAN packets to HTTP requests converter instance size."
}

variable "vxlan_id" {
  type        = number
  default     = 1377
  description = "VXLAN VNI, in VXLAN header."
}

variable "buffer_packet_expire" {
  type        = string
  default     = "30s"
  description = "The limit of packet caching for restore TCP session."
}

variable "buffer_size" {
  type        = string
  default     = "256MB"
  description = "Buffer size for restoring TCP sessions."
}

variable "mirror_endpoint" {
  type        = string
  description = "The endpoint for forward requests to."
}

variable "debug" {
  type        = bool
  default     = false
  description = "Enables goreplay to put requests into stdout too (so into log stream too)."
}

