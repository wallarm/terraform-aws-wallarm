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
  description = "Wallarm node token copied from the Wallarm Console UI. More details: https://docs.wallarm.com/user-guides/nodes/nodes/#creating-a-node"
}

variable "domain_name" {
  type        = string
  # default = "smth.example.tld"
  description = "Domain name to issue SSL certificate from AWS Certificate Manager (ACM) for. Once an SSL certificate is generated, a certificate and DNS records will be immediately bound to ALB. DNS zone of this domain must be presented in the AWS Route 53."
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
