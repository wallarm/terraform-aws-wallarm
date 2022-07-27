variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region. More details: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html"
}

variable "host" {
  type        = string
  default     = "api.wallarm.com"
  description = "Wallarm API server. Possible values: 'api.wallarm.com' for the EU Cloud, 'us1.api.wallarm.com' for the US Cloud. By default, 'api.wallarm.com'. More details: https://docs.wallarm.com/about-wallarm-waf/overview/#cloud"
}

variable "token" {
  type        = string
  description = "Wallarm node token copied from the Wallarm Console UI. More details: https://docs.wallarm.com/user-guides/nodes/nodes/#creating-a-node"
}
