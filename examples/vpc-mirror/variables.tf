variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region. More details: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html"
}

variable "host" {
  type        = string
  default     = "api.wallarm.com"
  description = "Wallarm API server. Possible values: 'api.wallarm.com' for the EU Cloud, 'us1.api.wallarm.com' for the US Cloud. By default, 'api.wallarm.com'. More details: https://docs.wallarm.com/about-wallarm-waf/overview/#cloud"
}

variable "token" {
  type        = string
  # default = "xxx-some-base64-xxx"
  description = "Wallarm node token copied from the Wallarm Console UI. More details: https://docs.wallarm.com/user-guides/nodes/nodes/#creating-a-node"
}

variable "vpc_id" {
  type        = string
  # default = "vpc-00000000"
  description = "ID of the AWS Virtual Private Cloud to deploy the Wallarm EC2 instance to. More details: https://docs.aws.amazon.com/managedservices/latest/userguide/find-vpc.html"
}

variable "private_subnets" {
  type        = list(string)
  # default = ["subnet-00000000", "subnet-11111111"]
  description = "List of AWS Virtual Private Cloud subnets IDs to deploy Wallarm EC2 instances in. The recommended value is private subnets configured for egress-only connections. More details: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html"
}

variable "asg_name" {
  type        = string
  # default = ""
  description = "AWS Auto Scaling Group name to attach to AWS VPC with the traffic mirroring enabled."
}
