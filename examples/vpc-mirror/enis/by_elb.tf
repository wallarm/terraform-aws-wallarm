### Example: Collect ENI IDs for ELB by public
### IP addresses
###
variable "public_ips" {
  type = list(string)
}

data "aws_network_interfaces" "example" {
  ### https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeNetworkInterfaces.html
  ###
  filter {
    name   = "vpc-id"
    values = [var.vpcid]
  }
  ### ALB and NLB not supported: 
  ###   https://docs.aws.amazon.com/vpc/latest/mirroring/traffic-mirroring-limits.html
  ###
  filter {
    name   = "attachment.instance-owner-id"
    values = ["amazon-elb"]
  }
  filter {
    name   = "association.public-ip"
    values = var.public_ips
  }
}

output "network_interfaces" {
  value = data.aws_network_interfaces.example.ids
}
