variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "AWS region. More details: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html"
}

variable "token" {
  type        = string
  description = "Wallarm node token copied from the Wallarm Console UI. More details: https://docs.wallarm.com/user-guides/nodes/nodes/#creating-a-node"
}

variable "apigw_name" {
  type        = string
  default     = "protected-by-wallarm"
  description = "Name of API Gateway to create for this demo."
}

variable "apigw_private" {
  type        = bool
  default     = false
  description = "Defines type of API Gateway to create. \"true\" creates \"PRIVATE\", and \"false\" creates \"REGIONAL\"."
}

variable "vpc_id" {
  type        = string
  description = "ID of the AWS Virtual Private Cloud to deploy the Wallarm EC2 instance to. More details: https://docs.aws.amazon.com/managedservices/latest/userguide/find-vpc.html"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of AWS Virtual Private Cloud subnets IDs to deploy an Application Load Balancer in. The recommended value is public subnets associated with a route table that has a route to an internet gateway. More details: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of AWS Virtual Private Cloud subnets IDs to deploy Wallarm EC2 instances in. The recommended value is private subnets configured for egress-only connections. More details: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html"
}
